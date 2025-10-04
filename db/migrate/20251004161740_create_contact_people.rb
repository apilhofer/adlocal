class CreateContactPeople < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_people do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :email
      t.string :phone
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end
  end
end
