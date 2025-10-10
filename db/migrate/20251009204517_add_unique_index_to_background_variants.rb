class AddUniqueIndexToBackgroundVariants < ActiveRecord::Migration[8.0]
  def change
    # Add unique index to ensure only one background variant per campaign per aspect
    add_index :background_variants, [:campaign_id, :aspect], unique: true
  end
end
