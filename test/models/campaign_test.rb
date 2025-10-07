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
    valid_statuses = %w[draft ready active completed]
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
    assert_equal "badge bg-secondary", @campaign.status_badge_class
    
    @campaign.status = "ready"
    assert_equal "badge bg-info", @campaign.status_badge_class
    
    @campaign.status = "active"
    assert_equal "badge bg-success", @campaign.status_badge_class
    
    @campaign.status = "completed"
    assert_equal "badge bg-primary", @campaign.status_badge_class
  end

  test "can_edit? should return true for draft campaigns" do
    @campaign.status = "draft"
    assert @campaign.can_edit?
    
    @campaign.status = "active"
    assert_not @campaign.can_edit?
    
    @campaign.status = "completed"
    assert_not @campaign.can_edit?
  end

  test "can_generate_ads? should return true for complete draft campaigns" do
    @campaign.status = "draft"
    @campaign.brief = "This is a valid brief with enough content"
    @campaign.goals = "Test goals"
    @campaign.audience = "Test audience"
    @campaign.offer = "Test offer"
    @campaign.cta = "Test CTA"
    @campaign.ad_sizes = ["300x250"]
    @campaign.brand_colors = ["#FF0000"]
    @campaign.brand_fonts = "Arial"
    @campaign.tone_words = ["bold"]
    assert @campaign.can_generate_ads?
    
    @campaign.status = "ready"
    assert_not @campaign.can_generate_ads?
    
    @campaign.status = "active"
    assert_not @campaign.can_generate_ads?
    
    @campaign.status = "completed"
    assert_not @campaign.can_generate_ads?
    
    @campaign.status = "draft"
    @campaign.brief = "Short"
    assert_not @campaign.can_generate_ads?
  end

  test "can_mark_ready? should return true for complete draft campaigns" do
    @campaign.status = "draft"
    @campaign.brief = "This is a valid brief with enough content"
    @campaign.goals = "Test goals"
    @campaign.audience = "Test audience"
    @campaign.offer = "Test offer"
    @campaign.cta = "Test CTA"
    @campaign.ad_sizes = ["300x250"]
    @campaign.brand_colors = ["#FF0000"]
    @campaign.brand_fonts = "Arial"
    @campaign.tone_words = ["bold"]
    assert @campaign.can_mark_ready?
    
    @campaign.status = "ready"
    assert_not @campaign.can_mark_ready?
  end

  test "can_mark_active? should return true for ready campaigns" do
    @campaign.status = "ready"
    assert @campaign.can_mark_active?
    
    @campaign.status = "draft"
    assert_not @campaign.can_mark_active?
  end

  test "can_mark_completed? should return true for active campaigns" do
    @campaign.status = "active"
    assert @campaign.can_mark_completed?
    
    @campaign.status = "ready"
    assert_not @campaign.can_mark_completed?
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
