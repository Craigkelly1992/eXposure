class AgencyRegistrationsController < Devise::RegistrationsController
  before_action :set_agency, only: [:edit, :update]

  # include SimpleCaptcha::ControllerHelpers
  def update
    successfully_updated = if needs_password?(@agency, params)
      @agency.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
    else
      # remove the virtual current_password attribute
      # update_without_password doesn't know how to ignore it
      params[:agency].delete(:current_password)
      @agency.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
    end

    if successfully_updated
      set_flash_message :notice, :updated, class: "alert alert-danger alert-dismissable"
      # Sign in the agency bypassing validation in case his password changed
      sign_in @agency, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end

  def edit
  end

  private
  def set_agency
    @agency = current_agency
  end

  def after_sign_up_path_for(resource)
    my_brands_path
  end

  def after_sign_in_path_for(resource)
    my_contests_path
  end

  def needs_password?(agency, params)
    agency.email != params[:agency][:email] || params[:agency][:password].present?
  end

  def agency_params
    params[:agency].permit(:first_name, :last_name, :phone, :company_name, :email, :password, :password_confirmation)
  end

  #Need :current_password for password update
  def agency_params_password_update
    params[:agency].permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end

  def agency_params_signup
    params[:agency].permit(:first_name, :last_name, :phone, :company_name, :email, :password, :password_confirmation)
    # params[:agency].permit(:remember_me, :agencyname, :type, :location, :latitude,
    # :longitude, :name, :email, :password, :password_confirmation, providers_attributes: [:id, :name, :token, :secret, :avatar_url, :agencyname, :email, :profile_url, :uid, :agency_id])
  end

end