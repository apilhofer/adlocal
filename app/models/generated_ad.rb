class GeneratedAd < ApplicationRecord
  belongs_to :campaign
  
  validates :variant_id, presence: true
  validates :ad_size, presence: true
  validates :headline, presence: true
  validates :subheadline, presence: true
  validates :call_to_action, presence: true
  validates :status, inclusion: { in: %w[generating completed failed] }
  
  scope :completed, -> { where(status: 'completed') }
  scope :by_variant, ->(variant_id) { where(variant_id: variant_id) }
  scope :by_size, ->(size) { where(ad_size: size) }
end
