# frozen_string_literal: true

class Campaign < ApplicationRecord
  belongs_to :business
  has_many_attached :inspiration_images

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :business, presence: true
  validates :brief, length: { minimum: 20 }, allow_blank: true
  validates :status, inclusion: { in: %w[draft active completed] }

  # JSON fields
  serialize :brand_colors, coder: JSON
  serialize :tone_words, coder: JSON
  serialize :ad_sizes, coder: JSON

  # Scopes
  scope :draft, -> { where(status: 'draft') }
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def brand_colors_array
    brand_colors || []
  end

  def tone_words_array
    tone_words || []
  end

  def ad_sizes_array
    ad_sizes || []
  end

  def has_inspiration_images?
    inspiration_images.attached?
  end

  def inspiration_images_count
    inspiration_images.count
  end

  def business_logo
    business.logo if business.logo.attached?
  end

  def status_badge_class
    case status
    when 'draft'
      'badge bg-secondary'
    when 'active'
      'badge bg-success'
    when 'completed'
      'badge bg-primary'
    else
      'badge bg-secondary'
    end
  end

  def can_edit?
    status == 'draft'
  end

  def can_generate_ads?
    # Campaign must be active and have all required information
    return false unless status == 'active'
    
    # Check for required fields
    required_fields_present = brief.present? && 
                              brief.length >= 20 && 
                              goals.present? && 
                              audience.present? && 
                              offer.present? && 
                              cta.present? &&
                              ad_sizes_array.any?
    
    # Check for brand profile (either campaign-specific or inherited from business)
    brand_profile_present = (brand_colors_array.any? || business.brand_colors_array.any?) &&
                           (brand_fonts.present? || business.brand_fonts.present?) &&
                           (tone_words_array.any? || business.tone_words_array.any?)
    
    required_fields_present && brand_profile_present
  end

  def completion_percentage
    total_fields = 8
    completed_fields = 0
    
    # Required fields
    completed_fields += 1 if brief.present? && brief.length >= 20
    completed_fields += 1 if goals.present?
    completed_fields += 1 if audience.present?
    completed_fields += 1 if offer.present?
    completed_fields += 1 if cta.present?
    completed_fields += 1 if ad_sizes_array.any?
    
    # Brand profile (check campaign or business defaults)
    completed_fields += 1 if (brand_colors_array.any? || business.brand_colors_array.any?) &&
                            (brand_fonts.present? || business.brand_fonts.present?) &&
                            (tone_words_array.any? || business.tone_words_array.any?)
    
    # Status
    completed_fields += 1 if status == 'active'
    
    (completed_fields.to_f / total_fields * 100).round
  end

  def missing_fields
    missing = []
    
    missing << "Creative Brief" if brief.blank? || brief.length < 20
    missing << "Goals" if goals.blank?
    missing << "Target Audience" if audience.blank?
    missing << "Offer Details" if offer.blank?
    missing << "Call to Action" if cta.blank?
    missing << "Ad Sizes" if ad_sizes_array.empty?
    
    # Check brand profile
    brand_missing = []
    brand_missing << "Brand Colors" if brand_colors_array.empty? && business.brand_colors_array.empty?
    brand_missing << "Brand Fonts" if brand_fonts.blank? && business.brand_fonts.blank?
    brand_missing << "Tone Words" if tone_words_array.empty? && business.tone_words_array.empty?
    
    missing << "Brand Profile (#{brand_missing.join(', ')})" if brand_missing.any?
    missing << "Campaign Status (must be Active)" if status != 'active'
    
    missing
  end
end
