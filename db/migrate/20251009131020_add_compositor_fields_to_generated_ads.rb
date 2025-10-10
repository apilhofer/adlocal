class AddCompositorFieldsToGeneratedAds < ActiveRecord::Migration[8.0]
  def change
    add_column :generated_ads, :background_image_url, :text
    add_column :generated_ads, :element_positions, :jsonb
    add_column :generated_ads, :final_image_url, :text
    add_column :generated_ads, :is_locked, :boolean, default: false
    add_column :generated_ads, :font_size, :integer
    add_column :generated_ads, :text_color, :string
    
    # Add index for better performance on element_positions queries
    add_index :generated_ads, :element_positions, using: :gin
  end
end
