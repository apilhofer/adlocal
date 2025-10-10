class GeneratedAd < ApplicationRecord
  belongs_to :campaign
  has_one_attached :final_image
  has_one_attached :background_image
  
  validates :variant_id, presence: true
  validates :ad_size, presence: true
  validates :headline, presence: true
  validates :subheadline, presence: true
  validates :call_to_action, presence: true
  validates :status, inclusion: { in: %w[generating completed failed] }
  validates :element_positions, presence: true
  
  scope :completed, -> { where(status: 'completed') }
  scope :by_variant, ->(variant_id) { where(variant_id: variant_id) }
  scope :by_size, ->(size) { where(ad_size: size) }
  scope :editable, -> { where(is_locked: false) }
  scope :locked, -> { where(is_locked: true) }
  
  def editable?
    !is_locked
  end

  def has_final_image?
    final_image_url.present?
  end
  
  # Helper method to get the background image URL
  def background_image_url
    return nil unless background_image.attached?
    Rails.application.routes.url_helpers.rails_blob_url(background_image, only_path: true)
  end
  
  # Helper method to get the full background image URL (including domain)
  def background_image_url_full
    return nil unless background_image.attached?
    Rails.application.routes.url_helpers.rails_blob_url(background_image)
  end

  def default_positions_for_size(ad_size = nil)
    size = ad_size || self.ad_size
    case size
    when "300x250"
      {
        "logo" => { "x" => 10, "y" => 10, "width" => 60, "height" => 60 },
        "headline" => { "x" => 150, "y" => 80, "fontSize" => 20, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 150, "y" => 120, "fontSize" => 14, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 75, "y" => 200, "width" => 150, "height" => 40, "fontSize" => 16, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "728x90"
      {
        "logo" => { "x" => 10, "y" => 15, "width" => 60, "height" => 60 },
        "headline" => { "x" => 364, "y" => 30, "fontSize" => 24, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 364, "y" => 60, "fontSize" => 16, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 600, "y" => 25, "width" => 120, "height" => 40, "fontSize" => 16, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "160x600"
      {
        "logo" => { "x" => 50, "y" => 20, "width" => 60, "height" => 60 },
        "headline" => { "x" => 80, "y" => 120, "fontSize" => 18, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 80, "y" => 160, "fontSize" => 14, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 30, "y" => 520, "width" => 100, "height" => 40, "fontSize" => 14, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "300x600"
      {
        "logo" => { "x" => 120, "y" => 20, "width" => 60, "height" => 60 },
        "headline" => { "x" => 150, "y" => 120, "fontSize" => 24, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 150, "y" => 180, "fontSize" => 16, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 100, "y" => 520, "width" => 100, "height" => 50, "fontSize" => 18, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "320x50"
      {
        "logo" => { "x" => 10, "y" => 5, "width" => 40, "height" => 40 },
        "headline" => { "x" => 200, "y" => 15, "fontSize" => 16, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 200, "y" => 35, "fontSize" => 12, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 250, "y" => 10, "width" => 60, "height" => 30, "fontSize" => 12, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "336x280"
      {
        "logo" => { "x" => 15, "y" => 15, "width" => 70, "height" => 70 },
        "headline" => { "x" => 168, "y" => 90, "fontSize" => 22, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 168, "y" => 130, "fontSize" => 15, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 85, "y" => 220, "width" => 170, "height" => 45, "fontSize" => 17, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "970x250"
      {
        "logo" => { "x" => 20, "y" => 20, "width" => 80, "height" => 80 },
        "headline" => { "x" => 485, "y" => 60, "fontSize" => 28, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 485, "y" => 100, "fontSize" => 18, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 750, "y" => 40, "width" => 180, "height" => 50, "fontSize" => 18, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    when "1080x1080"
      {
        "logo" => { "x" => 50, "y" => 50, "width" => 120, "height" => 120 },
        "headline" => { "x" => 540, "y" => 300, "fontSize" => 36, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 540, "y" => 380, "fontSize" => 24, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 340, "y" => 900, "width" => 400, "height" => 80, "fontSize" => 24, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    else
      {
        "logo" => { "x" => 10, "y" => 10, "width" => 60, "height" => 60 },
        "headline" => { "x" => 100, "y" => 50, "fontSize" => 20, "color" => "#000000", "align" => "center" },
        "subheadline" => { "x" => 100, "y" => 80, "fontSize" => 14, "color" => "#333333", "align" => "center" },
        "cta" => { "x" => 100, "y" => 120, "width" => 100, "height" => 40, "fontSize" => 16, "color" => "#ffffff", "bgColor" => "#ff0000" }
      }
    end
  end

  def unlock!
    update(is_locked: false)
  end
end
