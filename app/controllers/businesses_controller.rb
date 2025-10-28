# frozen_string_literal: true

class BusinessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [ :show, :edit, :update ]
  def show
    return redirect_to(new_business_path) unless @business
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
    permitted_params = params.require(:business).permit(
      :name, :type_of_business, :description, :website, :email, :phone,
      :address_1, :address_2, :city, :state, :postal_code, :country,
      :logo, :brand_fonts, :brand_colors, :tone_words,
      contact_people_attributes: [ :id, :first_name, :last_name, :title, :email, :phone, :_destroy ]
    )
    
    # Handle brand_colors - can be array or comma-separated string
    if permitted_params[:brand_colors].present?
      if permitted_params[:brand_colors].is_a?(String)
        permitted_params[:brand_colors] = permitted_params[:brand_colors].split(',').map(&:strip).reject(&:blank?)
      elsif permitted_params[:brand_colors].is_a?(Array)
        # Already an array, keep as is
      end
    else
      permitted_params[:brand_colors] = []
    end
    
    # Handle tone_words - can be array or comma-separated string
    if permitted_params[:tone_words].present?
      if permitted_params[:tone_words].is_a?(String)
        permitted_params[:tone_words] = permitted_params[:tone_words].split(',').map(&:strip).reject(&:blank?)
      elsif permitted_params[:tone_words].is_a?(Array)
        # Already an array, keep as is
      end
    else
      permitted_params[:tone_words] = []
    end
    
    # Handle empty brand_fonts string
    if permitted_params[:brand_fonts].present? && permitted_params[:brand_fonts].strip.blank?
      permitted_params[:brand_fonts] = nil
    elsif permitted_params[:brand_fonts].blank?
      permitted_params[:brand_fonts] = nil
    end
    
    permitted_params
  end
end
