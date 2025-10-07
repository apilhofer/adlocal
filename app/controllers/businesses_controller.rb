# frozen_string_literal: true

class BusinessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [ :show, :edit, :update ]
  def show
    redirect_to new_business_path unless current_user.business
  end

  def new
    redirect_to business_path and return if current_user.business
    @business = current_user.build_business
    @business.contact_people.build # Build one contact person for the form
  end

  def create
    @business = current_user.build_business(business_params)
    if @business.save
      redirect_to business_path, notice: 'Business profile created successfully!'
    else
      # Ensure we have at least one contact person for the form
      @business.contact_people.build if @business.contact_people.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @business.update(business_params)
      redirect_to business_path, notice: 'Business profile updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_business
    @business = current_user.business
  end

  def business_params
    params.require(:business).permit(
      :name, :type_of_business, :description, :website, :email, :phone,
      :address_1, :address_2, :city, :state, :postal_code, :country,
      :logo,
      contact_people_attributes: [ :id, :first_name, :last_name, :title, :email, :phone, :_destroy ]
    )
  end
end
