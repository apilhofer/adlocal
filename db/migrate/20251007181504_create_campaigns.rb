class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.references :business, null: false, foreign_key: true
      t.text :brief
      t.text :goals
      t.text :audience
      t.text :offer
      t.string :cta
      t.text :brand_colors
      t.string :brand_fonts
      t.text :tone_words
      t.string :status, default: 'draft', null: false
      t.text :ad_sizes

      t.timestamps
    end

    add_index :campaigns, :status
  end
end
