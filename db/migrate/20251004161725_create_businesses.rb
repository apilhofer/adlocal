# frozen_string_literal: true

class CreateBusinesses < ActiveRecord::Migration[8.0]
  def change
    create_table :businesses do |t|
      t.string :name
      t.text :description
      t.string :website
      t.string :email
      t.string :phone
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
