require "zlib"
require "json"
require "set"

# Adds the official CBSE, CISCE (ICSE/ISC), IB, Cambridge (IGCSE) and preschool directories to the
# school listings, deduplicated against each other and against the existing listings.
#
# db/data/school_directory_import_2026_10.json.gz was built offline from the five source
# spreadsheets and a snapshot of the production schools table:
#   inserts - schools not already listed (one row per school; dual-board schools list every board)
#   updates - existing listings matched to an official directory: board corrected / missing
#             phone, email, website filled, plus name-derived IB/Cambridge labels that no official
#             list confirms moved to "State Board". Each carries its previous values for rollback.
class ImportBoardSchoolDirectories < ActiveRecord::Migration[8.1]
  DATA = Rails.root.join("db/data/school_directory_import_2026_10.json.gz")
  BATCH = 1000

  class SchoolRow < ActiveRecord::Base
    self.table_name = "schools"
    self.inheritance_column = :_type_disabled
  end

  def up
    payload = load_payload
    marker  = payload.fetch("marker")

    SchoolRow.transaction do
      applied = skipped = 0
      payload.fetch("updates").each do |u|
        row = SchoolRow.find_by(id: u["id"])
        # only touch a listing that still looks like it did when the payload was built
        unless row && row.name == u["name"] && row.state == u["state"] && row.board == u["old_board"]
          skipped += 1
          next
        end
        attrs = u["set"].dup
        if attrs["board"] && row.description.present?
          attrs["description"] = row.description.sub("Affiliated with #{u['old_board']}", "Affiliated with #{attrs['board']}")
        end
        SchoolRow.where(id: row.id).update_all(attrs)
        applied += 1
      end
      say "updated #{applied} existing listings (#{skipped} skipped: changed since snapshot or not present)"

      existing = SchoolRow.pluck(:name, :district, :state, :affiliation_no, :address).map { |r| r.join("\u0001") }.to_set
      rows = payload.fetch("inserts").reject do |r|
        existing.include?([ r["name"], r["district"], r["state"], r["affiliation_no"], r["address"] ].join("\u0001"))
      end
      rows.each_slice(BATCH) do |batch|
        SchoolRow.insert_all(batch.map { |r| r.merge("created_at" => marker) }, record_timestamps: false)
      end
      say "inserted #{rows.size} new listings (#{payload['inserts'].size - rows.size} already present)"
    end
  end

  def down
    payload = load_payload
    SchoolRow.transaction do
      SchoolRow.where(created_at: payload.fetch("marker")).delete_all
      payload.fetch("updates").each do |u|
        row = SchoolRow.find_by(id: u["id"])
        next unless row && row.name == u["name"]
        attrs = u["was"].dup
        if u["set"]["board"] && row.description.present?
          attrs["description"] = row.description.sub("Affiliated with #{u['set']['board']}", "Affiliated with #{u['old_board']}")
        end
        SchoolRow.where(id: row.id).update_all(attrs)
      end
    end
  end

  private

  def load_payload
    JSON.parse(Zlib::GzipReader.open(DATA) { |gz| gz.read }.force_encoding(Encoding::UTF_8))
  end
end
