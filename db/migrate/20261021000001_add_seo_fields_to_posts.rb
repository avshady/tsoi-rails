class AddSeoFieldsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :meta_title,       :string
    add_column :posts, :meta_description, :text
    add_column :posts, :json_ld,          :text
    add_column :posts, :cover_image_alt,  :string
  end
end
