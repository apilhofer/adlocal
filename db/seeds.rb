# frozen_string_literal: true

# Create a sample user and business (idempotent)
user = User.find_or_create_by(email: "owner@example.com") do |u|
  u.password = "password"
end

unless user.business
  # Create business with validation context to skip logo requirement
  biz = user.build_business(
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
    website: "https://www.samplecoffee.com",
    brand_colors: ["#8B4513", "#D2691E", "#F4A460"],
    brand_fonts: "Georgia, serif",
    tone_words: ["cozy", "welcoming", "artisanal", "local"]
  )
  
  # Save without validation first
  biz.save!(validate: false)
  
  # Create a simple placeholder logo using a 1x1 transparent PNG
  placeholder_logo = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
  biz.logo.attach(
    io: StringIO.new(placeholder_logo),
    filename: 'sample_logo.png',
    content_type: 'image/png'
  )
  biz.contact_people.create!(
    first_name: "Alex",
    last_name: "Ng",
    title: "Owner",
    email: "alex@samplecoffee.com",
    phone: "(312) 555-0124"
  )
end

# Create sample campaigns
business = user.business
if business.campaigns.empty?
  # Draft campaign with inspiration images
  draft_campaign = business.campaigns.create!(
    name: "Summer Coffee Specials",
    status: "draft",
    brief: "Promote our new summer iced coffee drinks and cold brew selection. Target coffee lovers looking for refreshing options during hot weather.",
    goals: "Increase summer beverage sales by 30% and attract new customers during the hot season",
    audience: "Coffee enthusiasts aged 25-45 who appreciate quality and local sourcing",
    offer: "20% off all iced coffee drinks and free cold brew samples",
    cta: "Visit us today for a refreshing coffee experience",
    brand_colors: ["#8B4513", "#D2691E"],
    brand_fonts: "Georgia, serif",
    tone_words: ["refreshing", "artisanal", "local"],
    ad_sizes: ["300x250", "728x90", "320x50"]
  )

  # Active campaign with full brief
  active_campaign = business.campaigns.create!(
    name: "Grand Opening Celebration",
    status: "active",
    brief: "Announce our grand opening with special promotions and community events. Create excitement around our new location and build relationships with local residents.",
    goals: "Generate buzz for grand opening, attract 200+ visitors on opening day, establish community presence",
    audience: "Local residents, coffee lovers, families, remote workers, and community members",
    offer: "Free coffee for first 100 customers, 50% off all drinks for opening week, free pastries with purchase",
    cta: "Join us for our grand opening celebration this Saturday!",
    brand_colors: ["#8B4513", "#D2691E", "#F4A460"],
    brand_fonts: "Georgia, serif",
    tone_words: ["celebratory", "community", "welcoming", "exciting"],
    ad_sizes: ["300x250", "728x90", "160x600", "300x600"]
  )

  # Ready campaign (ads generated, ready to go live)
  ready_campaign = business.campaigns.create!(
    name: "Holiday Specials",
    status: "ready",
    brief: "Promote our holiday coffee blends and seasonal treats. Target customers looking for cozy winter beverages and gift options. Emphasize warmth, comfort, and holiday cheer.",
    goals: "Increase holiday season sales by 40%, promote gift cards and holiday merchandise",
    audience: "Coffee enthusiasts, gift shoppers, families celebrating holidays, office workers",
    offer: "20% off holiday blends, free gift wrapping, buy 2 get 1 free on seasonal treats",
    cta: "Get into the holiday spirit with our special blends!",
    brand_colors: ["#8B4513", "#D2691E"],
    brand_fonts: "Georgia, serif",
    tone_words: ["cozy", "festive", "warm", "welcoming"],
    ad_sizes: ["300x250", "728x90", "320x50"]
  )

  puts "Created sample campaigns:"
  puts "- #{draft_campaign.name} (#{draft_campaign.status})"
  puts "- #{ready_campaign.name} (#{ready_campaign.status})"
  puts "- #{active_campaign.name} (#{active_campaign.status})"
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
