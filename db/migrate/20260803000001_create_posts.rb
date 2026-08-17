class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string   :title,        null: false
      t.string   :slug,         null: false
      t.string   :author
      t.string   :category
      t.string   :cover_image
      t.text     :excerpt
      t.text     :body
      t.boolean  :published,    default: false, null: false
      t.datetime :published_at
      t.timestamps
    end

    add_index :posts, :slug, unique: true
    add_index :posts, [:published, :published_at]
  end
end
