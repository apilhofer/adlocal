class AdGenerationJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    
    begin
      # Broadcast start message
      broadcast_progress(campaign, "Starting ad generation...", 0)
      
      # Initialize generator
      generator = OpenaiAdGenerator.new(campaign)
      
      # Generate text content
      broadcast_progress(campaign, "Generating ad copy and concepts...", 25)
      text_response = generator.send(:generate_text_content)
      
      # Parse variants
      broadcast_progress(campaign, "Processing ad variants...", 40)
      variants = generator.send(:parse_text_response, text_response)
      
      # Generate images for each variant
      total_variants = variants.length
      variants.each_with_index do |variant, index|
        progress = 40 + (50 * (index + 1) / total_variants.to_f)
        broadcast_progress(campaign, "Generating image for #{variant[:variant_id]}...", progress.to_i)
        
        begin
          image_url = generator.send(:generate_image, variant[:image_prompt], variant[:ad_size], variant)
          variant[:image_url] = image_url
          variant[:status] = "completed"

          # Broadcast individual variant completion
          broadcast_variant_update(campaign, variant)
        rescue => e
          Rails.logger.error "Image generation failed for variant #{variant[:variant_id]}: #{e.message}"
          
          # Broadcast error and fail the entire job
          broadcast_error(campaign, "Image generation failed: #{e.message}")
          raise e
        end
      end
      
      # Final completion
      broadcast_progress(campaign, "Ad generation completed!", 100)
      broadcast_completion(campaign, variants)
      
    rescue => e
      broadcast_error(campaign, e.message)
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
  
  def broadcast_completion(campaign, variants)
    # Save all variants to database
    variants.each do |variant|
      begin
        Rails.logger.info "Saving variant: #{variant.inspect}"
        campaign.generated_ads.create!(
          variant_id: variant[:variant_id] || variant["variant_id"],
          ad_size: variant[:ad_size] || variant["ad_size"],
          headline: variant[:headline] || variant["headline"],
          subheadline: variant[:subheadline] || variant["subheadline"],
          call_to_action: variant[:call_to_action] || variant["call_to_action"],
          image_url: variant[:image_url] || variant["image_url"],
          reasoning: variant[:reasoning] || variant["reasoning"],
          status: variant[:status] || variant["status"] || "completed"
        )
        Rails.logger.info "Successfully saved variant"
      rescue => e
        Rails.logger.error "Failed to save variant: #{e.message}"
        Rails.logger.error "Variant data: #{variant.inspect}"
        raise e
      end
    end
    
    # Update campaign status to ready
    campaign.update!(status: 'ready')
    
    # Get the saved ads for broadcasting
    saved_ads = campaign.generated_ads.completed
    
    ActionCable.server.broadcast(
      "ad_generation_#{campaign.id}",
      {
        type: "completion",
        variants: saved_ads.map do |ad|
          {
            variant_id: ad.variant_id,
            headline: ad.headline,
            subheadline: ad.subheadline,
            call_to_action: ad.call_to_action,
            image_url: ad.image_url,
            ad_size: ad.ad_size,
            reasoning: ad.reasoning,
            status: ad.status
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
