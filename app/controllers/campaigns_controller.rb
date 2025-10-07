# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :generate_suggestions]

  def index
    @campaigns = @business.campaigns.recent
    
    # Filter by status if provided
    if params[:status].present? && %w[draft active completed].include?(params[:status])
      @campaigns = @campaigns.where(status: params[:status])
    end
  end

  def show
  end

  def new
    @campaign = @business.campaigns.build
    # Pre-populate with business brand profile if available
    if @business.has_brand_profile?
      @campaign.brand_colors = @business.brand_colors_array
      @campaign.brand_fonts = @business.brand_fonts
      @campaign.tone_words = @business.tone_words_array
    end
  end

  def create
    @campaign = @business.campaigns.build(campaign_params)
    
    if @campaign.save
      # Handle inspiration images upload
      if params[:campaign][:inspiration_images].present?
        @campaign.inspiration_images.attach(params[:campaign][:inspiration_images])
      end
      
      # Save brand profile to business if requested
      if params[:save_as_default] == '1'
        @business.update(
          brand_colors: @campaign.brand_colors,
          brand_fonts: @campaign.brand_fonts,
          tone_words: @campaign.tone_words
        )
      end
      
      redirect_to @campaign, notice: 'Campaign created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      # Handle inspiration images upload
      if params[:campaign][:inspiration_images].present?
        @campaign.inspiration_images.attach(params[:campaign][:inspiration_images])
      end
      
      # Save brand profile to business if requested
      if params[:save_as_default] == '1'
        @business.update(
          brand_colors: @campaign.brand_colors,
          brand_fonts: @campaign.brand_fonts,
          tone_words: @campaign.tone_words
        )
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

  def generate_suggestions
    if @campaign.brief.blank?
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

  def campaign_params
    params.require(:campaign).permit(
      :name, :brief, :goals, :audience, :offer, :cta,
      :brand_fonts, :status,
      brand_colors: [], tone_words: [], ad_sizes: []
    )
  end
end
