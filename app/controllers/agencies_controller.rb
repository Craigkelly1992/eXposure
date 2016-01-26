class AgenciesController < ApplicationController
  before_action :authenticate_agency!

  def change_password

  end

  def update_password
    password=params[:agency][:password]
    password_confirmation=params[:agency][:password_confirmation]
    if password.blank? or password_confirmation.blank?
      redirect_to change_password_path(current_agency), flash: { danger: 'Your password cannot be blank.' }, class: "alert alert-danger alert-dismissable"
      #render template: 'users/registrations/edit'
    elsif password == password_confirmation
      if password.length >= 4
        agency=current_agency
        current_agency.update_attributes(agency_params)
        sign_in agency, bypass: true
        redirect_to root_path(current_agency), flash: { success: 'Your password was changed.' }, class: "alert alert-info alert-dismissable"
      else
        redirect_to agencies_change_password_path(current_agency), flash: { danger: 'Your new password must contain at least 4 characters.' }, class: "alert alert-danger alert-dismissable"
      end
    else
      redirect_to agencies_change_password_path(current_agency), flash: { danger: "Passwords don't match." }, class: "alert alert-danger alert-dismissable"
    end

  end

  private
  def agency_params
    params[:agency].permit(:first_name, :last_name, :phone, :company_name, :email, :password, :password_confirmation, :current_password)
  end

end