class CreateSummitSpeakers < ActiveRecord::Migration[8.0]
  def change
    create_table :summit_speakers do |t|
      t.string :name, null: false
      t.string :title
      t.string :organisation
      t.string :photo
      t.string :accent_color, default: "#ff2a7f"
      t.integer :position, default: 0
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        [
          { name: "Laxmi Kumar",   title: "Director", organisation: "Avasara Academy",          photo: "/summit/assets/advisor_lakshmi.jpg?v=2", accent_color: "#ff2a7f", position: 1 },
          { name: "Sanjay Malpani", title: "Director", organisation: "Malpani Group of Schools", photo: "/summit/assets/advisor_sanjay.jpg?v=2",   accent_color: "#7c3aed", position: 2 },
          { name: "Piramal",        title: "Speaker",  organisation: "Piramal Foundation",        photo: "/summit/assets/advisor_parimal.jpg?v=2",  accent_color: "#2de67b", position: 3 }
        ].each do |attrs|
          execute <<~SQL
            INSERT INTO summit_speakers (name, title, organisation, photo, accent_color, position, created_at, updated_at)
            VALUES (#{quote(attrs[:name])}, #{quote(attrs[:title])}, #{quote(attrs[:organisation])}, #{quote(attrs[:photo])}, #{quote(attrs[:accent_color])}, #{attrs[:position]}, NOW(), NOW())
          SQL
        end
      end
    end
  end

  private

  def quote(str)
    "'#{str.gsub("'", "''")}'"
  end
end
