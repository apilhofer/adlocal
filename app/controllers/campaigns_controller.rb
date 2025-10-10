# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :generate_suggestions, :generate_ads, :delete_ads, :update_all_ad_positions, :render_all_ads, :unlock_all_ads, :regenerate_background, :background_variants, :proceed_to_editing]

  def index
    @campaigns = @business.campaigns.by_status_priority
    
    # Filter by status if provided
    if params[:status].present? && %w[draft ready active completed].include?(params[:status])
      @campaigns = @campaigns.where(status: params[:status])
    end
  end

  def show
  end

  def new
    @campaign = @business.campaigns.build
    # Pre-populate with business brand profile defaults
    @campaign.brand_colors = @business.brand_colors_array
    @campaign.brand_fonts = @business.brand_fonts
    @campaign.tone_words = @business.tone_words_array
  end

  def create
    @campaign = @business.campaigns.build(campaign_params)
    
    # Apply business defaults for any blank brand profile fields
    apply_business_defaults_to_campaign(@campaign)
    
    if @campaign.save
      # Handle inspiration images upload
      if params[:campaign][:inspiration_images].present?
        @campaign.inspiration_images.attach(params[:campaign][:inspiration_images])
      end
      
      redirect_to @campaign, notice: 'Campaign created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @campaign.assign_attributes(campaign_params)
    
    # Apply business defaults for any blank brand profile fields
    apply_business_defaults_to_campaign(@campaign)
    
    if @campaign.save
      # Handle inspiration images upload
      if params[:campaign][:inspiration_images].present?
        @campaign.inspiration_images.attach(params[:campaign][:inspiration_images])
      end
      
      redirect_to @campaign, notice: 'Campaign updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: 'Campaign deleted successfully!'
  end

  def generate_ads
    if @campaign.nil?
      render json: { 
        error: "Campaign not found" 
      }, status: :not_found
      return
    end

    if @campaign.can_generate_ads?
      # Start the background job for ad generation
      AdGenerationJob.perform_later(@campaign.id)
      
      render json: { 
        status: "started", 
        message: "Ad generation has started. You'll see real-time updates below." 
      }
    else
      render json: { 
        error: "Campaign is not ready for ad generation. Please complete all required fields." 
      }, status: :unprocessable_entity
    end
  end

  def delete_ads
    if @campaign.nil?
      redirect_to campaigns_path, alert: "Campaign not found"
      return
    end

    begin
      # Delete all generated ads for this campaign
      deleted_count = @campaign.generated_ads.count
      @campaign.generated_ads.destroy_all
      
      # Reset campaign status to draft
      @campaign.update_column(:status, 'draft')
      
      redirect_to campaign_path(@campaign), notice: "Successfully deleted #{deleted_count} generated ads. Campaign status reset to draft."
    rescue => e
      Rails.logger.error "Error deleting ads: #{e.message}"
      redirect_to campaign_path(@campaign), alert: "Error deleting ads: #{e.message}"
    end
  end

  def update_all_ad_positions
    updates = params[:updates] || []
    
    begin
      updates.each do |update|
        ad = @campaign.generated_ads.find(update[:ad_id])
        ad.update!(element_positions: update[:element_positions])
      end
      
      render json: { success: true, message: "All positions updated successfully" }
    rescue => e
      render json: { success: false, errors: [e.message] }
    end
  end

  def render_all_ads
    begin
      @campaign.generated_ads.editable.each do |ad|
        ImageCompositorService.new(ad).composite
      end
      
      render json: { success: true, message: "All ads rendered successfully" }
    rescue => e
      render json: { success: false, errors: [e.message] }
    end
  end

  def unlock_all_ads
    begin
      @campaign.generated_ads.locked.each do |ad|
        ad.unlock!
      end
      
      render json: { success: true, message: "All ads unlocked for editing" }
    rescue => e
      render json: { success: false, errors: [e.message] }
    end
  end

  def regenerate_background
    # Allow regeneration if campaign is complete (draft or ready status)
    if @campaign.can_generate_ads? || @campaign.status == 'ready'
      # Start the background job for background regeneration only
      RegenerateBackgroundJob.perform_later(@campaign.id)
      
      render json: { 
        status: "started", 
        message: "Background image regeneration has started." 
      }
    else
      render json: { 
        error: "Campaign is not ready for background regeneration." 
      }, status: :unprocessable_entity
    end
  end

  def background_variants
    variants = @campaign.background_variants.map do |variant|
      {
        aspect: variant.aspect,
        size: variant.size,
        image_url: variant.image_url_full || variant.image_url
      }
    end
    render json: variants
  end

  def proceed_to_editing
    begin
      # This action triggers the creation of GeneratedAd records with overlayed elements
      # The background image should already exist from the previous step
      if @campaign.has_background_image?
        # Create GeneratedAd records for each ad size with overlayed elements
        generator = OpenaiAdGenerator.new(@campaign)
        text_response = generator.send(:generate_text_content)
        variants = generator.send(:parse_text_response, text_response)
        
        @campaign.ad_sizes_array.each do |ad_size|
          variant = variants.first
          
          @campaign.generated_ads.create!(
            variant_id: variant[:variant_id] || variant["variant_id"],
            ad_size: ad_size,
            headline: variant[:headline] || variant["headline"],
            subheadline: variant[:subheadline] || variant["subheadline"],
            call_to_action: variant[:call_to_action] || variant["call_to_action"],
            background_image_url: @campaign.generated_ads.first&.background_image_url,
            element_positions: GeneratedAd.new.default_positions_for_size(ad_size),
            status: 'completed',
            is_locked: false,
            final_image_url: nil
          )
        end
        
        render json: { success: true, message: "Ready for editing" }
      else
        render json: { error: "No background image available" }, status: :unprocessable_entity
      end
    rescue => e
      render json: { success: false, error: e.message }
    end
  end

  def generate_suggestions
    if @campaign.brief.blank? || @campaign.brief.length < 20
      render json: { error: 'Brief is required for AI suggestions' }, status: :unprocessable_entity
      return
    end

    begin
      suggestions = OpenaiBriefSuggester.new(@campaign).call
      render json: suggestions
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      render json: { error: 'Unable to generate suggestions at this time' }, status: :service_unavailable
    end
  end

  private

  def set_business
    @business = current_user.business
    redirect_to new_business_path unless @business
  end

  def set_campaign
    @campaign = @business.campaigns.find(params[:id])
  end

  private

  def apply_business_defaults_to_campaign(campaign)
    # Apply business defaults for any blank brand profile fields
    campaign.brand_colors = campaign.brand_colors_array.any? ? campaign.brand_colors_array : @business.brand_colors_array
    campaign.brand_fonts = campaign.brand_fonts.present? ? campaign.brand_fonts : @business.brand_fonts
    campaign.tone_words = campaign.tone_words_array.any? ? campaign.tone_words_array : @business.tone_words_array
  end

  def campaign_params
    params.require(:campaign).permit(
      :name, :brief, :goals, :audience, :offer, :cta,
      :brand_fonts, :status,
      brand_colors: [], tone_words: [], ad_sizes: []
    )
  end
end
