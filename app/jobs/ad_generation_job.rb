class AdGenerationJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    download_service = ImageDownloadService.new
    
    begin
      # Broadcast start message
      broadcast_progress(campaign, "Starting ad generation...", 0)
      
      # Initialize generator
      generator = OpenaiAdGenerator.new(campaign)
      
      # Step 1: Generate ad copy variants (headline, subheadline, CTA) - ONCE
      broadcast_progress(campaign, "Generating ad copy...", 10)
      text_response = generator.send(:generate_text_content)
      variants = generator.send(:parse_text_response, text_response)
      
      # Step 2: Generate background images - THREE VARIANTS
      broadcast_progress(campaign, "Generating background images...", 30)
      background_variants = generator.generate_background_image
      
      # Save background variants to database with downloaded images
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
      
      # Broadcast background images completion
      broadcast_background_complete(campaign, background_variants)
      
      # Step 3: For each selected ad size, create GeneratedAd records with overlayed elements
      ad_sizes = campaign.ad_sizes_array
      total_sizes = ad_sizes.length
      
      ad_sizes.each_with_index do |ad_size, index|
        progress = 40 + (30 * (index + 1) / total_sizes.to_f)
        broadcast_progress(campaign, "Creating ad for #{ad_size}...", progress.to_i)
        
        # Choose the appropriate background variant based on ad size
        background_variant = choose_background_variant_from_db(campaign, ad_size)
        
        # Use the first variant for all ad sizes (can be enhanced later)
        variant = variants.first
        
        # Create GeneratedAd record with default positions
        generated_ad = campaign.generated_ads.create!(
          variant_id: variant[:variant_id] || variant["variant_id"],
          ad_size: ad_size,
          headline: variant[:headline] || variant["headline"],
          subheadline: variant[:subheadline] || variant["subheadline"],
          call_to_action: variant[:call_to_action] || variant["call_to_action"],
          element_positions: GeneratedAd.new.default_positions_for_size(ad_size),
          status: 'completed',
          is_locked: false,
          final_image_url: nil
        )
        
        # Attach the background image from the background variant
        if background_variant&.image&.attached?
          generated_ad.background_image.attach(background_variant.image.blob)
        end
        
        Rails.logger.info "Created GeneratedAd #{generated_ad.id} for size #{ad_size}"
      end
      
      # Step 4: Broadcast completion (no final images yet - user will position and render)
      broadcast_completion(campaign, "Background and text generated! Ready to position and render ads.")
      
    rescue => e
      Rails.logger.error "Ad generation failed for campaign #{campaign_id}: #{e.message}"
      Rails.logger.error "Full error details: #{e.inspect}"
      broadcast_error(campaign, "Ad generation failed: #{e.message}")
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
  
  def broadcast_variant_update(campaign, variant)
    ActionCable.server.broadcast(
      "ad_generation_#{campaign.id}",
      {
        type: "variant_update",
        variant: variant,
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

  def broadcast_completion(campaign, message)
    # Update campaign status to ready
    campaign.update!(status: 'ready')
    
    # Get the saved ads for broadcasting
    saved_ads = campaign.generated_ads.completed
    
    ActionCable.server.broadcast(
      "ad_generation_#{campaign.id}",
      {
        type: "completion",
        message: message,
        variants: saved_ads.map do |ad|
          {
            variant_id: ad.variant_id,
            headline: ad.headline,
            subheadline: ad.subheadline,
            call_to_action: ad.call_to_action,
            background_image_url: ad.background_image_url,
            ad_size: ad.ad_size,
            status: ad.status,
            is_locked: ad.is_locked
          }
        end,
        timestamp: Time.current
      }
    )
  end
  
  def broadcast_error(campaign, error_message)
    ActionCable.server.broadcast(
      "ad_generation_#{campaign.id}",
      {
        type: "error",
        error: error_message,
        timestamp: Time.current
      }
    )
  end
end
