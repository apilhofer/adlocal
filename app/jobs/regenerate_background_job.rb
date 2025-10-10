class RegenerateBackgroundJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    generator = OpenaiAdGenerator.new(campaign)
    download_service = ImageDownloadService.new
    
    Rails.logger.info "Starting background regeneration for campaign #{campaign_id}"
    
    begin
      # Broadcast start message
      broadcast_progress(campaign, "Regenerating background image...", 0)
      
      # Generate new background images - THREE VARIANTS
      broadcast_progress(campaign, "Generating new background images...", 50)
      background_variants = generator.generate_background_image
      
      # Update background variants in database with downloaded images
      background_variants.each do |variant|
        # Download and store the image locally
        blob = download_service.download_and_create_blob(
          variant[:url], 
          filename: "#{variant[:aspect]}_background_#{Time.current.to_i}"
        )
        
        if blob
          # Find existing variant by aspect or create new one
          background_variant = campaign.background_variants.find_or_initialize_by(aspect: variant[:aspect])
          
          # Purge old image if it exists
          background_variant.image.purge if background_variant.image.attached?
          
          # Update attributes and attach new image
          background_variant.size = variant[:size]
          background_variant.save!
          background_variant.image.attach(blob)
          
          Rails.logger.info "Updated background variant for #{variant[:aspect]}"
        else
          Rails.logger.error "Failed to download background image for #{variant[:aspect]}"
        end
      end
      
      # Update existing GeneratedAd records with new background images
      campaign.generated_ads.each do |ad|
        # Choose the appropriate background variant based on ad size
        background_variant = choose_background_variant_from_db(campaign, ad.ad_size)
        if background_variant&.image&.attached?
          # Remove old background image and attach new one
          ad.background_image.purge if ad.background_image.attached?
          ad.background_image.attach(background_variant.image.blob)
        end
      end
      
      # Broadcast completion
      broadcast_background_complete(campaign, background_variants)
      
    rescue => e
      # Enhanced error logging for development
      if Rails.env.development?
        Rails.logger.error "=== REGENERATE BACKGROUND JOB ERROR DEBUG ==="
        Rails.logger.error "Error Class: #{e.class}"
        
        # Safe error message extraction
        begin
          error_message_raw = e.message
        rescue => msg_error
          Rails.logger.error "Error getting message: #{msg_error.class} - #{msg_error}"
          error_message_raw = "Error message unavailable: #{msg_error}"
        end
        
        Rails.logger.error "Error Message: #{error_message_raw}"
        
        # Handle different error types
        if e.is_a?(Hash)
          Rails.logger.error "Error Hash: #{e.inspect}"
          error_message = e.to_s
        elsif e.respond_to?(:message)
          error_message = error_message_raw
        else
          error_message = e.to_s
        end
        
        Rails.logger.error "Final Error Message: #{error_message}"
        Rails.logger.error "Backtrace:"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.respond_to?(:backtrace)
        Rails.logger.error "=== END ERROR DEBUG ==="
      else
        # Production error handling
        begin
          error_message = if e.is_a?(Hash)
            e.to_s
          elsif e.respond_to?(:message)
            e.message
          else
            e.to_s
          end
        rescue => msg_error
          error_message = "Error processing failed: #{msg_error}"
        end
      end
      
      Rails.logger.error "Background regeneration failed for campaign #{campaign_id}: #{error_message}"
      broadcast_error(campaign, "Background regeneration failed: #{error_message}")
      raise e
    end
  end
  
  private
  
  def broadcast_progress(campaign, message, percentage)
    ActionCable.server.broadcast(
      "ad_generation_#{campaign.id}",
      {
        type: "progress",
        message: message,
        percentage: percentage,
        timestamp: Time.current
      }
    )
  end
  
  def broadcast_background_complete(campaign, background_variants)
    ActionCable.server.broadcast(
      "ad_generation_#{campaign.id}",
      {
        type: "background_complete",
        background_variants: background_variants,
        timestamp: Time.current
      }
    )
  end
  
  def choose_background_variant_from_db(campaign, ad_size)
    # Map ad sizes to appropriate background variants from database
    case ad_size
    when "728x90", "320x50", "970x250"  # Wide formats
      campaign.background_variants.find_by(aspect: "leaderboard") || campaign.background_variants.first
    when "160x600", "300x600"  # Tall formats
      campaign.background_variants.find_by(aspect: "skyscraper") || campaign.background_variants.first
    when "300x250", "336x280", "1080x1080"  # Square formats
      campaign.background_variants.find_by(aspect: "square") || campaign.background_variants.first
    else  # Fallback to square
      campaign.background_variants.find_by(aspect: "square") || campaign.background_variants.first
    end
  end

  def choose_background_variant(background_variants, ad_size)
    # Map ad sizes to appropriate background variants
    case ad_size
    when "728x90", "320x50"  # Wide formats
      background_variants.find { |v| v[:aspect] == "leaderboard" } || background_variants.first
    when "160x600", "300x600"  # Tall formats
      background_variants.find { |v| v[:aspect] == "skyscraper" } || background_variants.first
    else  # Square formats (300x250, etc.)
      background_variants.find { |v| v[:aspect] == "square" } || background_variants.first
    end
  end
end
