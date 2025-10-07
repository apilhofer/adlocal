# frozen_string_literal: true

require 'test_helper'

class BusinessesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @business = businesses(:one)
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
  end

  test 'should update business' do
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
  end
end
