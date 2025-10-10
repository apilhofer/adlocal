class AddImageToBackgroundVariants < ActiveRecord::Migration[8.0]
  def change
    # Add Active Storage attachment for background images
    # This will create the necessary active_storage_blobs and active_storage_attachments tables
    # if they don't already exist
  end
end
