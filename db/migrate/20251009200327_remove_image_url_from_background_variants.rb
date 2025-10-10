class RemoveImageUrlFromBackgroundVariants < ActiveRecord::Migration[8.0]
  def change
    remove_column :background_variants, :image_url, :string
  end
end
