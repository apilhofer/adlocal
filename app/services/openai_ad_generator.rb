class OpenaiAdGenerator
  include ActiveModel::Model
  
  attr_accessor :campaign, :client
  
  def initialize(campaign)
    @campaign = campaign
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_api_key,
      organization_id: Rails.application.credentials.openai_organization_id
    )
  end
  
  def generate_ads
    begin
      # Generate text content first
      text_response = generate_text_content
      
      # Parse the text response
      ad_variants = parse_text_response(text_response)
      
      # Generate images for each variant
      ad_variants.each_with_index do |variant, index|
        variant[:image_url] = generate_image(variant[:image_prompt], variant[:ad_size])
        variant[:variant_id] = "variant_#{index + 1}"
      end
      
      ad_variants
    rescue => e
      Rails.logger.error "OpenAI Ad Generation Error: #{e.message}"
      raise e
    end
  end
  
  def generate_background_image
    # Generate THREE background variants with different aspect ratios
    variants = []
    
    # Define the three aspect ratios and their composition guidance
    # Trying newer aspect ratios with explicit DALL-E 3 model
    aspect_configs = [
      {
        aspect: "leaderboard",
        size: "1792x1024",
        composition: "wide flow left→right, calm negative space band for future headline"
      },
      {
        aspect: "skyscraper", 
        size: "1024x1792",
        composition: "vertical flow top→bottom, calm negative space zones near top and bottom"
      },
      {
        aspect: "square",
        size: "1024x1024", 
        composition: "centered composition with soft gradients and negative space in upper third"
      }
    ]
    
    aspect_configs.each do |config|
      background_prompt = build_background_prompt_with_aspect(config[:aspect], config[:composition], config[:size])
      
      # Debug logging
      Rails.logger.info "=== OPENAI BACKGROUND GENERATION DEBUG (#{config[:aspect].upcase}) ==="
      Rails.logger.info "Prompt Length: #{background_prompt.length} characters"
      Rails.logger.info "Full Prompt:"
      Rails.logger.info background_prompt
      Rails.logger.info "=== END DEBUG ==="
      
      puts "=== OPENAI BACKGROUND GENERATION DEBUG (#{config[:aspect].upcase}) ==="
      puts "Prompt Length: #{background_prompt.length} characters"
      puts "Full Prompt:"
      puts background_prompt
      puts "=== END DEBUG ==="
      
      begin
        response = @client.images.generate(
          parameters: {
            model: "dall-e-3",
            prompt: background_prompt,
            size: config[:size],
            n: 1
          }
        )
        
        image_url = response.dig("data", 0, "url")
        variants << {
          aspect: config[:aspect],
          size: config[:size],
          url: image_url
        }
        
      rescue => e
        # Enhanced error logging for development
        if Rails.env.development?
          Rails.logger.error "=== OPENAI ERROR DEBUG (#{config[:aspect].upcase}) ==="
          Rails.logger.error "Error Class: #{e.class}"
          Rails.logger.error "Error Message: #{e.message}"
          
          # Try to extract more details from the error
          if e.respond_to?(:response) && e.response
            begin
              Rails.logger.error "HTTP Response Code: #{e.response.code}"
              Rails.logger.error "HTTP Response Body: #{e.response.body}"
            rescue => resp_error
              Rails.logger.error "Error accessing response: #{resp_error.class} - #{resp_error}"
              Rails.logger.error "Response object: #{e.response.inspect}"
            end
          elsif e.respond_to?(:code)
            Rails.logger.error "Error Code: #{e.code}"
          end
          
          # Check if it's a Faraday error (common with OpenAI client)
          if e.respond_to?(:response_body)
            Rails.logger.error "Response Body: #{e.response_body}"
          end
          
          # Check if error has additional details
          if e.respond_to?(:details)
            Rails.logger.error "Error Details: #{e.details}"
          end
          
          # Check if it's a Hash-like error
          if e.is_a?(Hash)
            Rails.logger.error "Error Hash: #{e.inspect}"
          end
          
          Rails.logger.error "Backtrace:"
          Rails.logger.error e.backtrace.first(10).join("\n")
          Rails.logger.error "=== END ERROR DEBUG ==="
          
          # Also output to console for immediate visibility
          puts "=== OPENAI ERROR DEBUG (#{config[:aspect].upcase}) ==="
          puts "Error Class: #{e.class}"
          puts "Error Message: #{e.message rescue 'No message method'}"
          
          if e.respond_to?(:response) && e.response
            begin
              puts "HTTP Response Code: #{e.response.code}"
              puts "HTTP Response Body: #{e.response.body}"
            rescue => resp_error
              puts "Error accessing response: #{resp_error.class} - #{resp_error}"
              puts "Response object: #{e.response.inspect}"
            end
          elsif e.respond_to?(:code)
            puts "Error Code: #{e.code}"
          end
          
          if e.respond_to?(:response_body)
            puts "Response Body: #{e.response_body}"
          end
          
          if e.respond_to?(:details)
            puts "Error Details: #{e.details}"
          end
          
          if e.is_a?(Hash)
            puts "Error Hash: #{e.inspect}"
          end
          
          puts "=== END ERROR DEBUG ==="
        end
        
        # Re-raise the error so it's still handled by the job
        raise e
      end
    end
    
    variants
  end
  
  def build_background_prompt_with_aspect(aspect, composition, size)
    business = @campaign.business
    
    # Get brand information - prioritize campaign overrides over business defaults
    brand_colors = if @campaign.brand_colors_array.any?
                     @campaign.brand_colors_array.join(", ")
                   elsif business.brand_colors_array.any?
                     business.brand_colors_array.join(", ")
                   else
                     "professional colors"
                   end
    
    brand_tone = if @campaign.tone_words_array.any?
                   @campaign.tone_words_array.join(", ")
                 elsif business.tone_words_array.any?
                   business.tone_words_array.join(", ")
                 else
                   "professional, modern"
                 end
    
    # Create prompt with aspect-specific composition guidance and size
    prompt = "Create a text-free abstract background.\n\nAspect: #{aspect} (#{size}).\nStyle: #{brand_tone}.\nPrimary palette only: #{brand_colors}.\nElements: organic gradients, soft textures, subtle patterns, gentle curves.\n\nComposition guidance: #{composition}.\n\nABSOLUTELY NO TEXT of any kind. NO letters, NO numerals, NO logos, NO icons, NO symbols, NO signage, NO labels, NO UI.\nNo objects or packaging. If a typographic or glyph-like mark would appear, replace it with texture or pattern.\nReserve calm negative space for later overlays."
    
    # Validate prompt length before returning
    validate_prompt_length(prompt)
    prompt
  end

  def build_background_prompt
    business = @campaign.business
    
    # Get brand information - prioritize campaign overrides over business defaults
    brand_colors = if @campaign.brand_colors_array.any?
                     @campaign.brand_colors_array.join(", ")
                   elsif business.brand_colors_array.any?
                     business.brand_colors_array.join(", ")
                   else
                     "professional colors"
                   end
    
    brand_tone = if @campaign.tone_words_array.any?
                   @campaign.tone_words_array.join(", ")
                 elsif business.tone_words_array.any?
                   business.tone_words_array.join(", ")
                 else
                   "professional, modern"
                 end
    
    business_type = business.type_of_business.present? ? business.type_of_business : "business"
    
    # Build campaign-specific context (shortened)
    campaign_context = build_campaign_context
    
    # Create a much shorter prompt to stay under 1000 characters
    prompt = "Create a text-free abstract background.\n\nStyle: #{brand_tone}.\nPrimary palette only: #{brand_colors}.\nElements: organic gradients, soft textures, subtle patterns, gentle curves.\n\nABSOLUTELY NO TEXT of any kind. NO letters, NO numerals, NO logos, NO icons, NO symbols, NO signage, NO labels, NO UI.\nNo objects or packaging. If a typographic or glyph-like mark would appear, replace it with texture or pattern.\nSquare orientation. Reserve calm negative space for later overlays."
    
    # Ensure prompt is under 1000 characters
    if prompt.length > 1000
      # Truncate campaign context if needed
      max_context_length = 1000 - prompt.length + campaign_context.length - 50 # Leave room for rest of prompt
      campaign_context = campaign_context[0, max_context_length] + "..."
      prompt = "Create a text-free abstract background.\n\nStyle: #{brand_tone}.\nPrimary palette only: #{brand_colors}.\nElements: organic gradients, soft textures, subtle patterns, gentle curves.\n\nABSOLUTELY NO TEXT of any kind. NO letters, NO numerals, NO logos, NO icons, NO symbols, NO signage, NO labels, NO UI.\nNo objects or packaging. If a typographic or glyph-like mark would appear, replace it with texture or pattern.\nSquare orientation. Reserve calm negative space for later overlays."
    end
    
    # Validate prompt length before returning
    validate_prompt_length(prompt)
    prompt
  end
  
  def build_campaign_context
    context_parts = []
    
    # Only include the most essential campaign details to keep prompt short
    if @campaign.brief.present?
      # Truncate brief to keep it concise
      brief = @campaign.brief.length > 100 ? @campaign.brief[0, 100] + "..." : @campaign.brief
      context_parts << "Brief: #{brief}"
    end
    
    if @campaign.offer.present?
      # Truncate offer to keep it concise
      offer = @campaign.offer.length > 80 ? @campaign.offer[0, 80] + "..." : @campaign.offer
      context_parts << "Offer: #{offer}"
    end
    
    if context_parts.any?
      context_parts.join(" | ")
    else
      "General #{@campaign.business.type_of_business} promotion"
    end
  end
  
  private
  
  def validate_prompt_length(prompt)
    if prompt.length > 1000
      Rails.logger.error "❌ PROMPT LENGTH VIOLATION: Prompt exceeds 1000 character limit (#{prompt.length} characters)"
      Rails.logger.error "❌ Prompt content: #{prompt}"
      
      # Provide helpful suggestions for shortening campaign elements
      suggestions = build_shortening_suggestions
      error_message = "Prompt exceeds 1000 character limit (#{prompt.length} characters). #{suggestions}"
      
      raise ArgumentError, error_message
    end
    
    if Rails.env.development?
      Rails.logger.info "✅ Prompt length validation passed: #{prompt.length} characters"
    end
    
    true
  end
  
  def build_shortening_suggestions
    suggestions = []
    
    # Check campaign brief length
    if @campaign.brief.present? && @campaign.brief.length > 200
      suggestions << "Consider shortening the campaign brief (currently #{@campaign.brief.length} characters)"
    end
    
    # Check other campaign fields
    if @campaign.goals.present? && @campaign.goals.length > 150
      suggestions << "Consider shortening the campaign goals (currently #{@campaign.goals.length} characters)"
    end
    
    if @campaign.audience.present? && @campaign.audience.length > 150
      suggestions << "Consider shortening the target audience description (currently #{@campaign.audience.length} characters)"
    end
    
    if @campaign.offer.present? && @campaign.offer.length > 150
      suggestions << "Consider shortening the offer details (currently #{@campaign.offer.length} characters)"
    end
    
    if @campaign.cta.present? && @campaign.cta.length > 100
      suggestions << "Consider shortening the call to action (currently #{@campaign.cta.length} characters)"
    end
    
    # Check business description
    if @campaign.business.description.present? && @campaign.business.description.length > 200
      suggestions << "Consider shortening the business description (currently #{@campaign.business.description.length} characters)"
    end
    
    # Check brand elements
    if @campaign.brand_colors_array.any? && @campaign.brand_colors_array.join(', ').length > 100
      suggestions << "Consider reducing the number of brand colors (currently #{@campaign.brand_colors_array.join(', ').length} characters)"
    end
    
    if @campaign.tone_words_array.any? && @campaign.tone_words_array.join(', ').length > 100
      suggestions << "Consider reducing the number of tone words (currently #{@campaign.tone_words_array.join(', ').length} characters)"
    end
    
    if suggestions.any?
      "To fix this, please: " + suggestions.join(", ") + "."
    else
      "Please review and shorten the campaign content to reduce the overall prompt length."
    end
  end
  
  def generate_text_content
    prompt = build_comprehensive_prompt
    
    # Validate prompt length before API call
    validate_prompt_length(prompt)
    
    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: system_prompt
          },
          {
            role: "user", 
            content: prompt
          }
        ],
        max_tokens: 2000,
        temperature: 0.8
      }
    )
    
    response.dig("choices", 0, "message", "content")
  end
  

  def generate_image(image_prompt, ad_size, variant_data = {})
    size_mapping = {
      "300x250" => "512x512", # Medium Rectangle - use square
      "728x90" => "512x512",  # Leaderboard - use square (will be cropped/resized)
      "160x600" => "512x512", # Wide Skyscraper - use square (will be cropped/resized)
      "300x600" => "512x512", # Half Page - use square (will be cropped/resized)
      "320x50" => "512x512"   # Mobile Banner - use square (will be cropped/resized)
    }
    
    image_size = size_mapping[ad_size] || "512x512"
    
    # Create a complete ad image with text overlay
    complete_ad_prompt = build_complete_ad_prompt(image_prompt, variant_data, ad_size)
    
    # Debug logging
    Rails.logger.info "=== OPENAI IMAGE GENERATION DEBUG ==="
    Rails.logger.info "Ad Size: #{ad_size}"
    Rails.logger.info "Mapped Size: #{image_size}"
    Rails.logger.info "Prompt Length: #{complete_ad_prompt.length} characters"
    Rails.logger.info "Full Prompt:"
    Rails.logger.info complete_ad_prompt
    Rails.logger.info "=== END DEBUG ==="
    
    puts "=== OPENAI IMAGE GENERATION DEBUG ==="
    puts "Ad Size: #{ad_size}"
    puts "Mapped Size: #{image_size}"
    puts "Prompt Length: #{complete_ad_prompt.length} characters"
    puts "Full Prompt:"
    puts complete_ad_prompt
    puts "=== END DEBUG ==="
    
    response = @client.images.generate(
      parameters: {
        prompt: complete_ad_prompt,
        size: image_size,
        n: 1
      }
    )
    
    response.dig("data", 0, "url")
  end
  
  def build_complete_ad_prompt(image_prompt, variant_data, ad_size)
    business = @campaign.business
    headline = variant_data[:headline] || variant_data["headline"]
    subheadline = variant_data[:subheadline] || variant_data["subheadline"]
    call_to_action = variant_data[:call_to_action] || variant_data["call_to_action"]
    
    # Layout instructions based on ad size
    layout_instructions = case ad_size
    when "300x250"
      "Layout: Portrait orientation, call-to-action button at bottom center."
    when "728x90"
      "Layout: Wide banner format, call-to-action button on right side."
    when "160x600"
      "Layout: Tall skyscraper format, call-to-action button at bottom."
    when "300x600"
      "Layout: Large vertical format, call-to-action button at bottom."
    when "320x50"
      "Layout: Mobile banner format, call-to-action on right side, compact design."
    else
      "Layout: Professional advertisement layout with clear hierarchy."
    end
    
    # Balanced prompt - more detailed than simple, less complex than full version
    <<~PROMPT
      #{image_prompt}
      
      Create a professional advertisement with a call-to-action button that says "#{call_to_action}" rendered directly onto the image.
      
      #{layout_instructions}
      
      Design: Clean, modern layout with the call-to-action button prominently displayed. Create space for headline and subheadline text to be overlaid later.
    PROMPT
  end
  
  def system_prompt
    <<~PROMPT
      You are an expert advertising copywriter and creative director specializing in local business marketing. 
      
      Your task is to create compelling, effective advertising content that drives local customer engagement and action.
      
      CRITICAL REQUIREMENTS:
      1. Use the provided call-to-action wording EXACTLY as specified
      2. Incorporate the business logo prominently and appropriately
      3. Reference inspiration images for visual style and mood
      4. Match the brand's tone and personality
      5. Create content that resonates with the target audience
      6. Ensure compliance with advertising standards
      
      OUTPUT FORMAT:
      Provide exactly 1 ad variant in the following JSON format:
      
      {
        "variants": [
          {
            "variant_id": "A",
            "headline": "Compelling headline (max 8 words)",
            "subheadline": "Supporting message (max 15 words)", 
            "call_to_action": "EXACT CTA text provided",
            "image_prompt": "Detailed visual description for image generation",
            "reasoning": "Why this approach will work for the target audience"
          }
        ]
      }
      
      Remember: Focus on local relevance, urgency, and clear value propositions that drive immediate action.
    PROMPT
  end
  
  def build_comprehensive_prompt
    business = @campaign.business
    
    prompt = <<~PROMPT
      BRIEF: #{@campaign.brief}
      GOALS: #{@campaign.goals}
      AUDIENCE: #{@campaign.audience}
      OFFER: #{@campaign.offer}
      CTA: #{@campaign.cta}
      
      BUSINESS: #{business.name} (#{business.type_of_business})
      DESCRIPTION: #{business.description}
      
      BRAND: Colors: #{@campaign.brand_colors_array.join(', ')} | Fonts: #{@campaign.brand_fonts} | Tone: #{@campaign.tone_words_array.join(', ')}
      
      #{build_inspiration_context}
      
      Create 1 compelling ad variant for sizes: #{@campaign.ad_sizes_array.join(', ')}. Include business logo prominently. Focus on single best creative approach.
    PROMPT
    
    # Validate prompt length before returning
    validate_prompt_length(prompt)
    prompt
  end
  
  def build_inspiration_context
    return "No inspiration images provided" unless @campaign.has_inspiration_images?
    
    context = "The following inspiration images should guide the visual style and mood:\n"
    @campaign.inspiration_images.each_with_index do |image, index|
      context += "- Inspiration Image #{index + 1}: Use this as a reference for visual style, color palette, mood, and overall aesthetic\n"
    end
    context
  end
  
  def parse_text_response(response_text)
    begin
      # Extract JSON from the response
      json_match = response_text.match(/\{.*\}/m)
      return [] unless json_match
      
      parsed_data = JSON.parse(json_match[0])
      variants = parsed_data["variants"] || []
      
      # Transform to our format and add ad sizes
      variants.map do |variant|
        @campaign.ad_sizes_array.map do |size|
          {
            variant_id: variant["variant_id"],
            headline: variant["headline"],
            subheadline: variant["subheadline"], 
            call_to_action: variant["call_to_action"],
            image_prompt: variant["image_prompt"],
            reasoning: variant["reasoning"],
            ad_size: size,
            status: "generating"
          }
        end
      end.flatten
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse OpenAI response: #{e.message}"
      []
    end
  end
end
