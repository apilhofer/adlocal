# frozen_string_literal: true

class Business < ApplicationRecord
  belongs_to :user
  has_many :contact_people, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_one_attached :logo

  # JSON fields for brand profile
  serialize :brand_colors, coder: JSON
  serialize :tone_words, coder: JSON

  # Essential business information
  validates :name, presence: true
  validates :type_of_business, presence: true
  validates :description, length: { minimum: 10 }, allow_blank: true
  validates :address_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true

  # Contact information
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { maximum: 30 }

  # Optional but validated when present
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w(http https)) }, allow_blank: true

  accepts_nested_attributes_for :contact_people, allow_destroy: true, reject_if: :all_blank

  # Brand profile methods
  def brand_colors_array
    brand_colors || []
  end

  def tone_words_array
    tone_words || []
  end

  def has_brand_profile?
    brand_colors_array.any? || brand_fonts.present? || tone_words_array.any?
  end

  def campaigns_count
    campaigns.count
  end

  def active_campaigns_count
    campaigns.active.count
  end
end
