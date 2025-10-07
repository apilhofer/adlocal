# frozen_string_literal: true

require 'test_helper'

class BusinessesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @business = businesses(:one)
    # Attach a logo to the business for testing
    unless @business.logo.attached?
      logo_file = fixture_file_upload('test_logo.png', 'image/png')
      @business.logo.attach(logo_file)
    end
    sign_in @user
  end

  test 'should get show' do
    get business_url
    assert_response :success
  end

  test 'should get new' do
    # Remove business first to test new
    @business.destroy
    get new_business_url
    assert_response :success
  end

  test 'should get edit' do
    get edit_business_url
    assert_response :success
  end

  test 'should create business' do
    # Remove business first to test create
    @business.destroy

    # Create a test logo file
    logo_file = fixture_file_upload('test_logo.png', 'image/png')

    assert_difference('Business.count') do
      post business_url, params: {
        business: {
          name: 'New Test Business',
          type_of_business: 'Professional Services',
          description: 'A test business description that is long enough',
          email: 'newtest@example.com',
          phone: '(555) 111-2222',
          address_1: '789 Test St',
          city: 'Chicago',
          state: 'IL',
          postal_code: '60603',
          country: 'United States',
          logo: logo_file,
          brand_colors: ['#FF0000', '#00FF00'],
          brand_fonts: 'Arial, sans-serif',
          tone_words: ['professional', 'modern'],
          contact_people_attributes: {
            '0' => {
              first_name: 'Test',
              last_name: 'Contact',
              title: 'Manager',
              email: 'test@example.com',
              phone: '(555) 111-2222'
            }
          }
        }
      }
    end
    assert_redirected_to business_url
    business = Business.last
    assert_equal 'New Test Business', business.name
    assert business.logo.attached?
  end

  test 'should update business' do
    patch business_url, params: {
      business: {
        name: 'Updated Business Name',
        type_of_business: 'Updated Business Type',
        brand_colors: '#0000FF, #FFFF00',
        brand_fonts: 'Times, serif',
        tone_words: 'elegant, classic'
      }
    }
    assert_redirected_to business_url
    @business.reload
    assert_equal 'Updated Business Name', @business.name
    assert_equal 'Updated Business Type', @business.type_of_business
    assert_equal ['#0000FF', '#FFFF00'], @business.brand_colors_array
    assert_equal 'Times, serif', @business.brand_fonts
    assert_equal ['elegant', 'classic'], @business.tone_words_array
  end

  test 'should parse comma-separated brand colors string' do
    patch business_url, params: {
      business: {
        brand_colors: '#FF0000, #00FF00, #0000FF',
        brand_fonts: 'Arial, sans-serif',
        tone_words: 'professional, modern, trustworthy'
      }
    }
    assert_redirected_to business_url
    @business.reload
    assert_equal ['#FF0000', '#00FF00', '#0000FF'], @business.brand_colors_array
    assert_equal 'Arial, sans-serif', @business.brand_fonts
    assert_equal ['professional', 'modern', 'trustworthy'], @business.tone_words_array
  end

  test 'should handle empty brand profile fields' do
    patch business_url, params: {
      business: {
        brand_colors: '',
        brand_fonts: '',
        tone_words: ''
      }
    }
    assert_redirected_to business_url
    @business.reload
    assert_equal [], @business.brand_colors_array
    assert_nil @business.brand_fonts
    assert_equal [], @business.tone_words_array
  end

  test 'should trim whitespace from comma-separated values' do
    patch business_url, params: {
      business: {
        brand_colors: ' #FF0000 , #00FF00 , #0000FF ',
        tone_words: ' professional , modern , trustworthy '
      }
    }
    assert_redirected_to business_url
    @business.reload
    assert_equal ['#FF0000', '#00FF00', '#0000FF'], @business.brand_colors_array
    assert_equal ['professional', 'modern', 'trustworthy'], @business.tone_words_array
  end

  test 'should update business without uploading new logo when logo exists' do
    # Ensure business has a logo
    assert @business.logo.attached?, "Business should have a logo for this test"
    
    patch business_url, params: {
      business: {
        name: 'Updated Business Name',
        type_of_business: 'Updated Business Type'
      }
    }
    assert_redirected_to business_url
    @business.reload
    assert_equal 'Updated Business Name', @business.name
    assert_equal 'Updated Business Type', @business.type_of_business
    # Logo should still be attached
    assert @business.logo.attached?, "Logo should still be attached after update"
  end
end
