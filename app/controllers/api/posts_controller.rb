class API::PostsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!, only: [:create, :my, :like, :unlike, :update]
  respond_to :json
  include ApplicationHelper
  def create
    @post = current_user.posts.build(post_params)
    logger.info "------------------- log post param when create -------------------------------"
    logger.info post_params
    if @post.save
      respond_with @post, only: [:id, :contest_id, :uploader_id, :text, :cached_votes_up, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
    else
      respond_with @post.errors, status: :unprocessable_entity, location: "/"
    end
  end

  def update
    @post = Post.find_by_id(params[:id])
    logger.info "---------------------------------- log post param when update #########################"
    if @post.update_attributes(post_params)
      respond_with @post do |format|
        format.json {render json: @post, only: [:id, :contest_id, :uploader_id, :text, :cached_votes_up, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"}
      end
    else
      logger.info "################## post not updated #####"
      logger.info @post.errors
      respond_with @post.errors, status: :unprocessable_entity, location: "/"
    end
  end

  def show
    @post = Post.find(params[:id])
    logger.info "################## post #{@post.as_json}"
    if params[:user_token]
      respond_with @post, only: [:id, :contest_id, :uploader_id, :text, :cached_votes_up, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
    else
      respond_with @post, only: [:id, :contest_id, :uploader_id, :text, :cached_votes_up, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand], location: "/"
    end
  end

  def show_without_authenticate
    @post = Post.find(params[:id])
    logger.info "################## post #{@post.as_json} without authenticate"
    respond_with render_post_with_include_comments(@post), location: "/"
  end

  def index
    @posts = Post.all.paginate(page: params[:page]).order(created_at: :desc)
    respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
  end

  def by_user
    @posts = Post.where(uploader_id: params[:user_id]).paginate(page: params[:page]).order(created_at: :desc)
    respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
  end

  def by_contest
    @posts = Post.where(contest_id: params[:contest_id]).paginate(page: params[:page]).order(created_at: :desc)
    respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
  end

  def by_brand
    @posts = Post.where("contest_id in (select id from contests where brand_id = ?)", params[:brand_id]).paginate(page: params[:page]).order(created_at: :desc)
    respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
  end

  def stream
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: false
      set_current_user
      user = current_user
      @posts = Post.where("uploader_id in (?)", user.following_users.pluck(:id)).paginate(page: params[:page]).order(created_at: :desc)
      respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
    else
      @posts = Post.all.paginate(page: params[:page]).order(created_at: :desc)
      respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand], location: "/"
    end
  end

  def my
    @posts = current_user.posts.paginate(page: params[:page]).order(created_at: :desc)
    respond_with @posts, only: [:contest_id, :uploader_id, :text, :cached_votes_up, :id, :created_at], methods: [:image_url, :image_url_square, :image_url_preview, :image_url_thumb, :brand, :current_user_likes], location: "/"
  end

  def comments
    list = Comment.includes(:user).where(post_id: params[:id]).paginate(page: params[:page]).order(created_at: :asc)
    @comments = comment_response_with_include_user_avatar_url(list)
    respond_with @comments, location: "/"
  end

  def like
    post = Post.find(params[:id])
    user = current_user
    like = user.likes post
    post_owner = post.user
    post_owner.update_attributes(cached_score: post_owner.cached_score + 1)
    Notification.create(sender_id: user.id, receiver_id: post_owner.id,
      text: "#{user.full_name} liked your photo on eXposure!", sender_type: "user", type: "like", post_id: post.id,
      sender_picture: user.profile_picture_url_thumb, sender_name: user.full_name, contest_id: post.contest_id)
    json = {status: like, like: user.voted_for?(post)}
    respond_with json, location: "/"
  end

  def unlike
    post = Post.find(params[:id])
    user = current_user
    like = user.unlike post
    post_owner = post.user
    post_owner.update_attributes(cached_score: post_owner.cached_score - 1)
    json = {status: like, like: current_user.voted_for?(post)}
    respond_with json, location: "/"
  end

  private

  def post_params
    params[:post].permit(:contest_id, :image_data, :text)
  end
end