# frozen_string_literal: true

class AdCompositorController < ApplicationController
  before_action :authenticate_user!
  before_action :set_generated_ad
  before_action :ensure_user_owns_campaign

  def show
    # Load the compositor interface
    @element_positions = @generated_ad.element_positions || @generated_ad.default_positions_for_size
    @business_logo = @generated_ad.campaign.business.logo if @generated_ad.campaign.business.logo.attached?
  end

  def update_positions
    if @generated_ad.update(element_positions: params[:element_positions])
      render json: { success: true, message: "Positions updated successfully" }
    else
      render json: { success: false, errors: @generated_ad.errors.full_messages }
    end
  end

  def render_final
    begin
      # Call the Image Compositor Service
      final_image_url = ImageCompositorService.new(@generated_ad).composite
      
      redirect_to campaign_path(@generated_ad.campaign), 
                  notice: "Ad successfully rendered! Final image is ready."
    rescue => e
      Rails.logger.error "Failed to render final ad: #{e.message}"
      redirect_to compose_generated_ad_path(@generated_ad), 
                  alert: "Failed to render final ad: #{e.message}"
    end
  end

  def unlock
    @generated_ad.unlock!
    redirect_to compose_generated_ad_path(@generated_ad), 
                notice: "Ad unlocked for editing."
  end

  private

  def set_generated_ad
    @generated_ad = GeneratedAd.find(params[:id])
  end

  def ensure_user_owns_campaign
    unless @generated_ad.campaign.business.user == current_user
      redirect_to campaigns_path, alert: "You don't have permission to access this ad."
    end
  end
end
