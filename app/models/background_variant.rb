class BackgroundVariant < ApplicationRecord
  belongs_to :campaign
  
  # Active Storage attachment for the background image
  has_one_attached :image
  
  validates :aspect, presence: true, inclusion: { in: %w[leaderboard skyscraper square] }
  validates :size, presence: true
  validates :aspect, uniqueness: { scope: :campaign_id }
  
  # Helper method to get the image URL
  def image_url
    return nil unless image.attached?
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
  end
  
  # Helper method to get the full image URL (including domain)
  def image_url_full
    return nil unless image.attached?
    Rails.application.routes.url_helpers.rails_blob_url(image)
  end
end
