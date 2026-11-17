class AddPublishAtToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :publish_at, :datetime
    add_index  :posts, [ :published, :publish_at ]
  end
end
