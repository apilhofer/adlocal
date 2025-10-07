require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @business = Business.new(
      name: "Test Business",
      type_of_business: "Retail Store",
      description: "A test business description",
      email: "test@example.com",
      phone: "(555) 123-4567",
      address_1: "123 Test St",
      city: "Test City",
      state: "TS",
      postal_code: "12345",
      country: "Test Country",
      user: @user
    )
  end

  test "should be valid" do
    assert @business.valid?
  end

  test "name should be present" do
    @business.name = nil
    assert_not @business.valid?
  end

  test "type_of_business should be present" do
    @business.type_of_business = nil
    assert_not @business.valid?
  end

  test "email should be present" do
    @business.email = nil
    assert_not @business.valid?
  end

  test "email should be valid format" do
    @business.email = "invalid_email"
    assert_not @business.valid?
  end

  test "phone should be present" do
    @business.phone = nil
    assert_not @business.valid?
  end

  test "phone should not be too long" do
    @business.phone = "a" * 31
    assert_not @business.valid?
  end

  test "address_1 should be present" do
    @business.address_1 = nil
    assert_not @business.valid?
  end

  test "city should be present" do
    @business.city = nil
    assert_not @business.valid?
  end

  test "state should be present" do
    @business.state = nil
    assert_not @business.valid?
  end

  test "postal_code should be present" do
    @business.postal_code = nil
    assert_not @business.valid?
  end

  test "country should be present" do
    @business.country = nil
    assert_not @business.valid?
  end

  test "description should be at least 10 characters when present" do
    @business.description = "short"
    assert_not @business.valid?
  end

  test "description can be blank" do
    @business.description = nil
    assert @business.valid?
  end

  test "website should be valid URL when present" do
    @business.website = "invalid_url"
    assert_not @business.valid?
  end

  test "website can be blank" do
    @business.website = nil
    assert @business.valid?
  end

  test "should belong to user" do
    assert_respond_to @business, :user
  end

  test "should have many contact people" do
    assert_respond_to @business, :contact_people
  end

  test "should have one attached logo" do
    assert_respond_to @business, :logo
  end
end
