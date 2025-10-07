# frozen_string_literal: true

require 'test_helper'

class ContactPeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @business = businesses(:one)
    @contact_person = contact_people(:one)
    sign_in @user
  end

  test 'should get new' do
    get new_business_contact_person_url(@business)
    assert_response :success
  end

  test 'should create contact person' do
    assert_difference('ContactPerson.count') do
      post business_contact_people_url(@business), params: {
        contact_person: {
          first_name: 'New',
          last_name: 'Contact',
          title: 'Director',
          email: 'newcontact@example.com',
          phone: '(555) 999-8888'
        }
      }
    end
    assert_redirected_to business_url
  end

  test 'should get edit' do
    get edit_business_contact_person_url(@business, @contact_person)
    assert_response :success
  end

  test 'should update contact person' do
    patch business_contact_person_url(@business, @contact_person), params: {
      contact_person: {
        first_name: 'Updated',
        last_name: 'Name'
      }
    }
    assert_redirected_to business_url
    @contact_person.reload
    assert_equal 'Updated', @contact_person.first_name
    assert_equal 'Name', @contact_person.last_name
  end
end
