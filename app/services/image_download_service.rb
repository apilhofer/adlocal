# frozen_string_literal: true

class ImageDownloadService
  def initialize
    @client = HTTParty
  end

  # Download image from URL and attach to Active Storage
  # Returns the blob key for the attached image
  def download_and_attach(url, filename: nil)
    return nil if url.blank?

    begin
      # Download the image
      response = @client.get(url, timeout: 30)
      
      if response.success?
        # Generate filename if not provided
        filename ||= generate_filename(url)
        
        # Create a temporary file
        temp_file = Tempfile.new([filename, '.png'])
        temp_file.binmode
        temp_file.write(response.body)
        temp_file.rewind
        
        # Create Active Storage blob
        blob = ActiveStorage::Blob.create_and_upload!(
          io: temp_file,
          filename: filename,
          content_type: 'image/png'
        )
        
        # Clean up temp file
        temp_file.close
        temp_file.unlink
        
        Rails.logger.info "Successfully downloaded and stored image: #{filename}"
        blob.key
      else
        Rails.logger.error "Failed to download image from #{url}: #{response.code}"
        nil
      end
    rescue => e
      Rails.logger.error "Error downloading image from #{url}: #{e.message}"
      nil
    end
  end

  # Download image and return the blob directly (for attaching to models)
  def download_and_create_blob(url, filename: nil)
    return nil if url.blank?

    begin
      # Download the image
      response = @client.get(url, timeout: 30)
      
      if response.success?
        # Generate filename if not provided
        filename ||= generate_filename(url)
        
        # Create a temporary file
        temp_file = Tempfile.new([filename, '.png'])
        temp_file.binmode
        temp_file.write(response.body)
        temp_file.rewind
        
        # Create Active Storage blob
        blob = ActiveStorage::Blob.create_and_upload!(
          io: temp_file,
          filename: filename,
          content_type: 'image/png'
        )
        
        # Clean up temp file
        temp_file.close
        temp_file.unlink
        
        Rails.logger.info "Successfully downloaded and created blob: #{filename}"
        blob
      else
        Rails.logger.error "Failed to download image from #{url}: #{response.code}"
        nil
      end
    rescue => e
      Rails.logger.error "Error downloading image from #{url}: #{e.message}"
      nil
    end
  end

  private

  def generate_filename(url)
    # Extract a unique identifier from the URL or generate one
    uri = URI.parse(url)
    path_parts = uri.path.split('/')
    if path_parts.any?
      # Use the last part of the URL path as filename base
      base_name = path_parts.last
      base_name = base_name.split('.').first if base_name.include?('.')
      base_name = base_name.presence || 'image'
    else
      base_name = 'image'
    end
    
    # Add timestamp to ensure uniqueness
    "#{base_name}_#{Time.current.to_i}"
  end
end
