class API::RankingsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!
  before_filter :set_current_user
  respond_to :json

  def global
    @users = User.all.order(cached_score: :desc).limit(50)
    respond_with @users, only: [:id, :email, :first_name, :last_name, :username, :phone, :cached_score], methods: [:profile_picture_url, :background_picture_url, :current_user_following], location: "/"
  end

  def followers
    if current_user.count_user_followers > 0
      @users = User.where("id = ? or id in (?)", current_user.id, current_user.user_followers.pluck(:id)).order(cached_score: :desc)
      respond_with @users, only: [:id, :email, :first_name, :last_name, :username, :phone, :cached_score], methods: [:profile_picture_url, :background_picture_url, :current_user_following], location: "/"
    else
      json = {status: true, message: "Current user has no followers."}
      respond_with json, location: "/"
    end
  end

  def following
    if current_user.following_users_count > 0
      @users = User.where("id = ? or id in (?)", current_user.id, current_user.following_users.pluck(:id)).order(cached_score: :desc)
      respond_with @users, only: [:id, :email, :first_name, :last_name, :username, :phone, :cached_score], methods: [:profile_picture_url, :background_picture_url, :current_user_following], location: "/"
    else
      json = {status: true, message: "Current user is not following anyone."}
      respond_with json, location: "/"
    end
  end

end