# frozen_string_literal: true

class ContactPerson < ApplicationRecord
  belongs_to :business

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, length: { maximum: 30 }, allow_blank: true

  def name
    "#{first_name} #{last_name}".strip
  end
end
