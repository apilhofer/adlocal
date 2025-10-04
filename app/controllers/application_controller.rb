# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  #redirect to business profile after sign in
  def after_sign_in_path_for(resource)
    current_user.business ? business_path : new_business_path
  end
end
