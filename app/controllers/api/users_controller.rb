class API::UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!, only: [:index, :update_my_profile, :destroy, :profile, :follow, :unfollow, :check_follow, :save_token,
                                                   :search, :followers, :following, :get_all_expose_of_user, :update_facebook, :update_twitter, :update_instagram]
  respond_to :html, :json
  include ApplicationHelper
  def index
  end

  def get_users
    @users = User.all
    respond_with @users, only: [:email, :username]
  end

  def show
    @user = User.find(params[:id])
    send_user_json(@user) # this method is in the application controller
  end

  def profile
    @user = current_user
    send_user_json(@user, true)
  end

  def search
    query = params[:q]
    users = User.where('username like ? or first_name like ? or last_name like ?', query, query, query).paginate(page: params[:page])
    respond_with users, only: [:id, :email, :first_name, :last_name, :username, :phone, :description], methods: [:profile_picture_url, :profile_picture_url_thumb, :profile_picture_url_preview, :profile_picture_url_square, :background_picture_url, :background_picture_url_preview, :posts, :follow_count, :followers_count], location: "/"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user, store: false
      send_user_json(@user, true)
    else
      #json = {status: false, message: @user.errors.full_messages.join(", ")}
      logger.info "################## user was not created"
      @json = {status: false, message: "API Access denied"}
      respond_with @json, status: :unprocessable_entity, location: "/"
    end
  end

  def save_token
    user = User.find(params[:id])
    unless params[:device_token].blank?
      if current_user == user
        if user.update_attributes(device_token: params[:device_token])
          json = {status: true, message: "Token saved."}
          respond_with json, location: "/"
        else
          json = {status: false, message: "Token saved unsuccess."}
          respond_with json, status: :unprocessable_entity, location: "/"
        end
      end
    else
      json = {status: false, message: "Token saved unsuccess."}
      respond_with json, status: :unprocessable_entity, location: "/"
    end
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers
    respond_with @users, only: [:id, :email, :first_name, :last_name, :username, :phone, :description], methods: [:profile_picture_url, :profile_picture_url_thumb, :profile_picture_url_preview, :profile_picture_url_square, :background_picture_url, :background_picture_url_preview, :posts, :follow_count, :followers_count, :current_user_following], location: "/"
  end

  def following
    @user = User.find(params[:id])
    @users = @user.all_following
    respond_with @users, only: [:id, :email, :first_name, :last_name, :username, :phone, :description], methods: [:profile_picture_url, :profile_picture_url_thumb, :profile_picture_url_preview, :profile_picture_url_square, :background_picture_url, :background_picture_url_preview, :posts, :follow_count, :followers_count, :current_user_following], location: "/"
  end

  def update_my_profile
    @user = current_user
    if @user.update_attributes(user_params)
      send_user_json(@user, true)
    else
      @json = {status: false, message: @user.errors.full_messages.join(", ")}
      logger.info "################## user was not updated"
      respond_with @json, status: :unprocessable_entity, location: "/"
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user == current_user
      @user.destroy
      @json = {status: true, message: "Account deleted"}
      respond_with @json
    else
      @json = {status: false, message: "Access denied"}
      respond_with @json, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by_email(params[:user_email])
    if @user && @user.valid_password?(params[:user_password])
      send_user_json(@user, true)
    else
      @json = {status: false, message: "Invalid login or password"}
      respond_with @json, status: :unprocessable_entity
    end

  end

  def contests
    @user = User.find(params[:id])
    @contests = @user.contests
    respond_with @contests, methods: [:brand_name, :picture_url], location: "/"
  end

  def follow
    followed = User.find(params[:id])
    current_user.follow(followed)
    json = {status: true, following: true}
    respond_with json, location: "/"
  end

  def unfollow
    followed = User.find(params[:id])
    current_user.stop_following(followed)
    json = {status: true, following: false}
    respond_with json, location: "/"
  end

  def check_follow
    followed = User.find(params[:id])
    json = {status: true, following: current_user.following?(followed)}
    respond_with json, location: "/"
  end

  def get_all_expose_of_user
    sum = 0
    user = current_user
    json = {total_xp: user.cached_score}
    respond_with json, location: "/"
  end

  def update_facebook
    user = current_user
    if user.update(facebook: params[:facebook])
      json = {status: true}
      respond_with json, location: "/"
    else
      json = {status: false, message: "Update facebook error"}
      respond_with json, status: :unprocessable_entity, location: "/"
    end
  end

  def update_twitter
    user = current_user
    if user.update(twitter: params[:twitter])
      json = {status: true}
      respond_with json, location: "/"
    else
      json = {status: false, message: "Update twitter error"}
      respond_with json, status: :unprocessable_entity, location: "/"
    end
  end

  def update_instagram
    user = current_user
    if user.update(instagram: params[:instagram])
      json = {status: true}
      respond_with json, location: "/"
    else
      json = {status: false, message: "Update instagram error"}
      respond_with json, status: :unprocessable_entity, location: "/"
    end
  end

  private

  def user_params
    params[:user].permit(:first_name, :last_name, :phone, :email, :password, :device_token, :username, :description, :profile_picture, :background_picture, :facebook, :twitter, :instagram)
  end

end