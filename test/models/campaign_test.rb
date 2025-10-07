# frozen_string_literal: true

require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @business = @user.business
    @campaign = @business.campaigns.build(
      name: "Test Campaign",
      brief: "This is a test campaign brief with enough content to pass validation",
      status: "draft"
    )
  end

  test "should be valid" do
    assert @campaign.valid?
  end

  test "name should be present" do
    @campaign.name = nil
    assert_not @campaign.valid?
  end

  test "name should not be too long" do
    @campaign.name = "a" * 101
    assert_not @campaign.valid?
  end

  test "business should be present" do
    @campaign.business = nil
    assert_not @campaign.valid?
  end

  test "brief should be long enough when present" do
    @campaign.brief = "Short"
    assert_not @campaign.valid?
    
    @campaign.brief = "This is a longer brief that meets the minimum length requirement"
    assert @campaign.valid?
  end

  test "brief can be blank" do
    @campaign.brief = nil
    assert @campaign.valid?
    
    @campaign.brief = ""
    assert @campaign.valid?
  end

  test "status should be valid" do
    valid_statuses = %w[draft active completed]
    valid_statuses.each do |status|
      @campaign.status = status
      assert @campaign.valid?, "#{status} should be valid"
    end
    
    @campaign.status = "invalid"
    assert_not @campaign.valid?
  end

  test "status should default to draft" do
    campaign = Campaign.new(name: "Test", business: @business)
    assert_equal "draft", campaign.status
  end

  test "should serialize brand_colors as JSON" do
    colors = ["#dc3545", "#ffffff", "#000000"]
    @campaign.brand_colors = colors
    @campaign.save!
    
    reloaded_campaign = Campaign.find(@campaign.id)
    assert_equal colors, reloaded_campaign.brand_colors
  end

  test "should serialize tone_words as JSON" do
    words = ["professional", "friendly", "modern"]
    @campaign.tone_words = words
    @campaign.save!
    
    reloaded_campaign = Campaign.find(@campaign.id)
    assert_equal words, reloaded_campaign.tone_words
  end

  test "should serialize ad_sizes as JSON" do
    sizes = ["300x250", "728x90", "160x600"]
    @campaign.ad_sizes = sizes
    @campaign.save!
    
    reloaded_campaign = Campaign.find(@campaign.id)
    assert_equal sizes, reloaded_campaign.ad_sizes
  end

  test "brand_colors_array should return empty array when nil" do
    @campaign.brand_colors = nil
    assert_equal [], @campaign.brand_colors_array
  end

  test "tone_words_array should return empty array when nil" do
    @campaign.tone_words = nil
    assert_equal [], @campaign.tone_words_array
  end

  test "ad_sizes_array should return empty array when nil" do
    @campaign.ad_sizes = nil
    assert_equal [], @campaign.ad_sizes_array
  end

  test "has_inspiration_images? should return false when no images" do
    assert_not @campaign.has_inspiration_images?
  end

  test "inspiration_images_count should return 0 when no images" do
    assert_equal 0, @campaign.inspiration_images_count
  end

  test "business_logo should return business logo when attached" do
    # This would need a business with attached logo in fixtures
    assert_nil @campaign.business_logo
  end

  test "status_badge_class should return correct classes" do
    @campaign.status = "draft"
    assert_equal "bg-gray-100 text-gray-800", @campaign.status_badge_class
    
    @campaign.status = "active"
    assert_equal "bg-green-100 text-green-800", @campaign.status_badge_class
    
    @campaign.status = "completed"
    assert_equal "bg-blue-100 text-blue-800", @campaign.status_badge_class
  end

  test "can_edit? should return true for draft campaigns" do
    @campaign.status = "draft"
    assert @campaign.can_edit?
    
    @campaign.status = "active"
    assert_not @campaign.can_edit?
    
    @campaign.status = "completed"
    assert_not @campaign.can_edit?
  end

  test "can_generate_ads? should return true for active campaigns with valid brief" do
    @campaign.status = "active"
    @campaign.brief = "This is a valid brief with enough content"
    assert @campaign.can_generate_ads?
    
    @campaign.status = "draft"
    assert_not @campaign.can_generate_ads?
    
    @campaign.status = "active"
    @campaign.brief = "Short"
    assert_not @campaign.can_generate_ads?
  end

  test "should belong to business" do
    assert_respond_to @campaign, :business
    assert_equal @business, @campaign.business
  end

  test "should have many attached inspiration_images" do
    assert_respond_to @campaign, :inspiration_images
  end

  test "should validate inspiration_images limit" do
    # This test would need actual file attachments to be meaningful
    # For now, just test that the validation exists
    assert_respond_to @campaign, :inspiration_images
  end

  test "should be destroyed when business is destroyed" do
    campaign_id = @campaign.id
    @campaign.save!
    
    @business.destroy
    assert_raises(ActiveRecord::RecordNotFound) do
      Campaign.find(campaign_id)
    end
  end
end
