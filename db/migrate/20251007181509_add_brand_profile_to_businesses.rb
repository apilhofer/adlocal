class AddBrandProfileToBusinesses < ActiveRecord::Migration[8.0]
  def change
    add_column :businesses, :brand_colors, :text
    add_column :businesses, :brand_fonts, :string
    add_column :businesses, :tone_words, :text
  end
end
