class SiteContent < ApplicationRecord
  self.table_name  = "site_content"
  self.primary_key = "key"

  def self.get(key)
    find_by(key: key)&.value
  end

  def self.set(key, value)
    record = find_or_initialize_by(key: key)
    record.value = value
    record.save!
  end

  def self.get_json(key)
    raw = get(key)
    raw ? JSON.parse(raw) : {}
  rescue JSON::ParserError
    {}
  end

  def self.set_json(key, hash)
    set(key, hash.to_json)
  end
end
