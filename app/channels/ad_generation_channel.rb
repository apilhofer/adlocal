class AdGenerationChannel < ApplicationCable::Channel
  def subscribed
    campaign = Campaign.find(params[:campaign_id])
    
    # Ensure user can only access their own campaign
    if current_user && campaign.business.user == current_user
      stream_from "ad_generation_#{campaign.id}"
      Rails.logger.info "User #{current_user.id} subscribed to ad generation for campaign #{campaign.id}"
    else
      Rails.logger.warn "Unauthorized subscription attempt for campaign #{params[:campaign_id]}"
      reject
    end
  end

  def unsubscribed
    Rails.logger.info "User unsubscribed from ad generation channel"
  end
end
