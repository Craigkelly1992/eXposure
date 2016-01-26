class API::BrandsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!, only: [:follow, :unfollow, :check_follow]
  respond_to :json

  def index
    @brands = Brand.all.paginate(page: params[:page]).order(created_at: :desc)
    respond_with @brands, methods: [:picture_url, :picture_url_preview, :picture_url_square, :picture_url_thumb], location: "/"
  end

  def show
    @brand = Brand.find(params[:id])
    impressionist(@brand, "brandview")
    respond_with @brand, methods: [:picture_url, :picture_url_preview, :picture_url_square, :picture_url_thumb,
                                   :background_url, :background_url_preview, :background_url_square, :background_url_thumb,:submissions_mobile, :submissions_count, :winners_count, :winners, :followers_count, :followers_list], location: "/"
  end

  def follow
    brand = Brand.find(params[:id])
    current_user.follow(brand)
    json = {status: true, following: true}
    respond_with json, location: "/"
  end

  def unfollow
    brand = Brand.find(params[:id])
    current_user.stop_following(brand)
    json = {status: true, following: false}
    respond_with json, location: "/"
  end

  def check_follow
    brand = Brand.find(params[:id])
    json = {status: true, following: current_user.following?(brand)}
    respond_with json, location: "/"
  end

  def click
    if params[:target] && ["website", "facebook", "twitter", "instagram"].include?(params[:target])
      @brand = Brand.find(params[:id])
      impressionist(@brand, params[:target])
      @json = {status: true}
      respond_with @json, location: "/"
    else
      @json = {status: false, message: "Wrong or no target specified"}
      respond_with @json, status: :unprocessable_entity, location: "/"
    end
  end

end