class AddPortalToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :portal_token, :string, limit: 64
    add_column :schools, :portal_email, :string, limit: 150
    add_index  :schools, :portal_token, unique: true
  end
end
