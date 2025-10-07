class ContactPeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business
  before_action :set_contact, only: [:edit, :update, :destroy]

  def index
    @contacts = @business.contact_people
  end

  def new
    @contact = @business.contact_people.new
  end

  def create
    @contact = @business.contact_people.new(contact_params)
    if @contact.save
      redirect_to business_path, notice: "Contact added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to business_path, notice: "Contact updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to business_contact_people_path, notice: "Contact removed."
  end

  private
  def set_business
    @business = current_user.business
    return redirect_to(new_business_path) unless @business
  end

  def set_contact
    @contact = @business.contact_people.find(params[:id])
  end

  def contact_params
    params.require(:contact_person).permit(:first_name, :last_name, :title, :email, :phone)
  end
end

