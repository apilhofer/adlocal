class CleanupDuplicateBackgroundVariants20251009204400 < ActiveRecord::Migration[8.0]
  def up
    # Remove duplicate background variants, keeping only the most recent one for each campaign/aspect combination
    execute <<~SQL
      DELETE FROM background_variants 
      WHERE id NOT IN (
        SELECT DISTINCT ON (campaign_id, aspect) id
        FROM background_variants
        ORDER BY campaign_id, aspect, created_at DESC
      )
    SQL
  end

  def down
    # This migration cannot be reversed as we're deleting data
    raise ActiveRecord::IrreversibleMigration
  end
end
