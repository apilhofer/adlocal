class CreateGeneratedAds < ActiveRecord::Migration[8.0]
  def change
    create_table :generated_ads do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :variant_id
      t.string :ad_size
      t.text :headline
      t.text :subheadline
      t.text :call_to_action
      t.text :image_url
      t.text :reasoning
      t.string :status

      t.timestamps
    end
  end
end
