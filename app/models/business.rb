class Business < ApplicationRecord
  belongs_to :user
  has_many :contact_people, dependent: :destroy
  has_one_attached :logo

  # Essential business information
  validates :name, presence: true
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
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  accepts_nested_attributes_for :contact_people, allow_destroy: true, reject_if: :all_blank
end
