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
  
  private
  
  def generate_text_content
    prompt = build_comprehensive_prompt
    
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
      "300x250" => "1024x1024", # Medium Rectangle - use square for flexibility
      "728x90" => "1792x256",   # Leaderboard - wide format
      "160x600" => "512x1792",  # Wide Skyscraper - tall format  
      "300x600" => "1024x1792", # Half Page - tall format
      "320x50" => "1792x256"    # Mobile Banner - wide format
    }
    
    image_size = size_mapping[ad_size] || "1024x1024"
    
    # Create a complete ad image with text overlay
    complete_ad_prompt = build_complete_ad_prompt(image_prompt, variant_data, ad_size)
    
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
    
    # Simplified prompt to avoid content policy issues
    <<~PROMPT
      #{image_prompt}
      
      Create a professional advertisement with:
      - Business name: #{business.name}
      - Main headline: "#{headline}"
      - Supporting text: "#{subheadline}"
      - Call to action: "#{call_to_action}"
      
      Style: Clean, modern design with high contrast text overlay on the background image.
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
    
    <<~PROMPT
      CAMPAIGN BRIEF:
      #{@campaign.brief}
      
      CAMPAIGN GOALS:
      #{@campaign.goals}
      
      TARGET AUDIENCE:
      #{@campaign.audience}
      
      OFFER DETAILS:
      #{@campaign.offer}
      
      CALL TO ACTION (USE EXACTLY):
      #{@campaign.cta}
      
      BUSINESS INFORMATION:
      Name: #{business.name}
      Type: #{business.type_of_business}
      Description: #{business.description}
      
      BRAND PROFILE:
      Brand Colors: #{@campaign.brand_colors_array.join(', ')}
      Brand Fonts: #{@campaign.brand_fonts}
      Tone Words: #{@campaign.tone_words_array.join(', ')}
      
      VISUAL INSPIRATION:
      #{build_inspiration_context}
      
      LOGO REQUIREMENTS:
      The business logo must be prominently featured in each ad. Consider how to integrate it naturally while maintaining visual hierarchy and readability.
      
      AD SIZES TO GENERATE:
      #{@campaign.ad_sizes_array.join(', ')}
      
      Create 1 compelling ad variant that will resonate with the target audience, drive the campaign goals, and incorporate all the above elements effectively. Focus on the single best creative approach that maintains brand consistency.
    PROMPT
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
