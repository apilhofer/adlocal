# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :generate_suggestions, :generate_ads, :delete_ads]

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
