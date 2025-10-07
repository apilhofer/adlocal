# frozen_string_literal: true

class AssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business
  before_action :set_campaign

  def create
    if params[:inspiration_images].present?
      @campaign.inspiration_images.attach(params[:inspiration_images])
      render json: { 
        success: true, 
        message: 'Images uploaded successfully',
        images_count: @campaign.inspiration_images.count
      }
    else
      render json: { error: 'No images provided' }, status: :unprocessable_entity
    end
  end

  def destroy
    attachment = @campaign.inspiration_images.find(params[:id])
    attachment.purge
    render json: { 
      success: true, 
      message: 'Image removed successfully',
      images_count: @campaign.inspiration_images.count
    }
  end

  private

  def set_business
    @business = current_user.business
    redirect_to new_business_path unless @business
  end

  def set_campaign
    @campaign = @business.campaigns.find(params[:campaign_id])
  end
end
