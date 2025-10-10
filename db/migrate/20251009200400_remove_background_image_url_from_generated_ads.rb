class RemoveBackgroundImageUrlFromGeneratedAds < ActiveRecord::Migration[8.0]
  def change
    remove_column :generated_ads, :background_image_url, :string
  end
end
