class CreateBackgroundVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :background_variants do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :aspect
      t.string :size
      t.string :image_url

      t.timestamps
    end
  end
end
