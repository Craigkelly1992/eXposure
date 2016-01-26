class ApplicationController < ActionController::Base
	before_filter :configure_devise_params, if: :devise_controller?
	before_filter :set_current_agency
	before_action :signout_if_disabled
	respond_to :html, :json
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #protected

  def set_current_user
    User.current = current_user
  end

  def set_current_agency
    Agency.current = current_agency
  end

  def configure_devise_params
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:address, :latitude,
      :longitude, :name, :email, :phone, :password, :password_confirmation, :first_name, :last_name, :company_name)
    end
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:remember_me, :first_name, :last_name, :company_name, :email, :phone, :password, :password_confirmation)}
  end

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: false
      set_current_user
    else
      @json = {status: false, message: "API Access denied"}
      respond_with @json, status: :unprocessable_entity, location: "/"
    end
  end

  def send_user_json(user, token=false)

    if token

      respond_with user, only: [:id, :email, :first_name, :last_name, :username, :phone, :authentication_token, :description, :facebook, :twitter, :instagram],
                         methods: [:profile_picture_url, :profile_picture_url_thumb, :profile_picture_url_preview, :profile_picture_url_square, :background_picture_url, :background_picture_url_preview, :posts, :follow_count,:followers_count],
                         location: "/"

    else

      respond_with user, only: [:id, :email, :first_name, :last_name, :username, :phone, :description, :facebook, :twitter, :instagram],
                         methods: [:profile_picture_url, :profile_picture_url_thumb, :profile_picture_url_preview, :profile_picture_url_square, :background_picture_url, :background_picture_url_preview, :posts, :follow_count, :followers_count],
                         location: "/"

    end

  end

  def signout_if_disabled

    if current_user && !current_user.enabled?
      sign_out current_user
    end

    if current_agency && !current_agency.enabled?
      sign_out current_agency
    end

    if current_admin && !current_admin.enabled?
      sign_out current_admin
    end
  end

  def after_sign_in_path_for(resource)
    if current_admin
      admin_users_path
    else
      root_path
    end
  end

end
