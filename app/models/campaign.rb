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
    status == 'active' && brief.present? && brief.length >= 20
  end
end
