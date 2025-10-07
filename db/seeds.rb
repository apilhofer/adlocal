# frozen_string_literal: true

# Create a sample user and business (idempotent)
user = User.find_or_create_by(email: "owner@example.com") do |u|
  u.password = "password"
end

unless user.business
  biz = user.create_business!(
    name: "Sample Coffee Shop",
    type_of_business: "Restaurant",
    description: "A cozy neighborhood coffee shop serving locally roasted beans and fresh pastries.",
    email: "info@samplecoffee.com",
    phone: "(312) 555-0123",
    address_1: "123 Michigan Avenue",
    address_2: "Suite 200",
    city: "Chicago",
    state: "IL",
    postal_code: "60601",
    country: "United States",
    website: "https://www.samplecoffee.com"
  )
  biz.contact_people.create!(
    first_name: "Alex",
    last_name: "Ng",
    title: "Owner",
    email: "alex@samplecoffee.com",
    phone: "(312) 555-0124"
  )
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
