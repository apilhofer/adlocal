# frozen_string_literal: true

class OpenaiBriefSuggester
  def initialize(campaign)
    @campaign = campaign
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_api_key,
      organization_id: Rails.application.credentials.openai_organization_id
    )
  end

  def call
    return { error: 'OpenAI API key not configured' } unless Rails.application.credentials.openai_api_key.present?

    prompt = build_prompt
    response = @client.chat(
      parameters: {
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: 'You are a marketing expert helping local businesses create effective advertising campaigns. Provide structured, actionable suggestions to improve their creative briefs.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      }
    )

    if response.dig('choices', 0, 'message', 'content')
      parse_suggestions(response.dig('choices', 0, 'message', 'content'))
    else
      { error: 'Failed to generate suggestions' }
    end
  rescue StandardError => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    { error: 'Unable to generate suggestions at this time' }
  end

  private

  def build_prompt
    business_info = {
      name: @campaign.business.name,
      type: @campaign.business.type_of_business,
      description: @campaign.business.description
    }

    brand_info = {
      colors: @campaign.brand_colors_array.join(', '),
      fonts: @campaign.brand_fonts,
      tone: @campaign.tone_words_array.join(', ')
    }

    <<~PROMPT
      Business Information:
      - Name: #{business_info[:name]}
      - Type: #{business_info[:type]}
      - Description: #{business_info[:description]}

      Brand Profile:
      - Colors: #{brand_info[:colors]}
      - Fonts: #{brand_info[:fonts]}
      - Tone: #{brand_info[:tone]}

      Current Campaign Brief:
      #{@campaign.brief}

      Additional Context:
      - Goals: #{@campaign.goals}
      - Target Audience: #{@campaign.audience}
      - Offer: #{@campaign.offer}
      - Call to Action: #{@campaign.cta}

      Please provide 3-5 specific suggestions to improve this creative brief. Focus on:
      1. Enhanced headline/hook that grabs attention
      2. Clearer value proposition
      3. More compelling call-to-action
      4. Better audience targeting
      5. Stronger campaign goals

      Format your response as a JSON object with keys like "headline", "value_proposition", "call_to_action", "audience_targeting", and "goals". Each value should be a specific, actionable suggestion.
    PROMPT
  end

  def parse_suggestions(content)
    # Try to extract JSON from the response
    json_match = content.match(/\{.*\}/m)
    
    if json_match
      JSON.parse(json_match[0])
    else
      # Fallback: create structured suggestions from the text
      create_fallback_suggestions(content)
    end
  rescue JSON::ParserError
    create_fallback_suggestions(content)
  end

  def create_fallback_suggestions(content)
    suggestions = {}
    
    # Extract suggestions based on common patterns
    content.split(/\n+/).each do |line|
      line = line.strip
      next if line.empty?
      
      if line.match?(/headline|hook/i)
        suggestions['headline'] = line.gsub(/^\d+\.?\s*/, '').gsub(/headline|hook/i, '').strip
      elsif line.match?(/value proposition|value prop/i)
        suggestions['value_proposition'] = line.gsub(/^\d+\.?\s*/, '').gsub(/value proposition|value prop/i, '').strip
      elsif line.match?(/call.?to.?action|cta/i)
        suggestions['call_to_action'] = line.gsub(/^\d+\.?\s*/, '').gsub(/call.?to.?action|cta/i, '').strip
      elsif line.match?(/audience|target/i)
        suggestions['audience_targeting'] = line.gsub(/^\d+\.?\s*/, '').gsub(/audience|target/i, '').strip
      elsif line.match?(/goal/i)
        suggestions['goals'] = line.gsub(/^\d+\.?\s*/, '').gsub(/goal/i, '').strip
      end
    end
    
    # If no structured suggestions found, provide generic ones
    if suggestions.empty?
      suggestions = {
        'headline' => 'Consider adding a compelling headline that immediately captures attention',
        'value_proposition' => 'Clarify what makes your business unique and why customers should choose you',
        'call_to_action' => 'Add a clear, action-oriented call-to-action that tells customers what to do next'
      }
    end
    
    suggestions
  end
end
