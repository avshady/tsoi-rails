class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :school_name
      t.string :service
      t.text :message
      t.string :status

      t.timestamps
    end
  end
end
