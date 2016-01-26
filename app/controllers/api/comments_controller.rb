class API::CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!
  include ApplicationHelper
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      @comments = comment_response_with_include_user_avatar_url(@post.comments.paginate(page: params[:page]).order(created_at: :asc))
      respond_with @comments, location: "/"
    else
      respond_with @comment.errors, status: :unprocessable_entity, location: "/"
    end
  end

  private

  def comment_params
    params[:comment].permit(:text, :post_id)
  end
  def comment_response_with_include_user_avatar_url(comments)
    com = []
    comments.each do |comment|
      tmp_hash = comment.as_json()
      tmp_hash[:user_avatar_url] = comment.user.profile_picture_url_thumb
      com << tmp_hash
    end
    com
  end
end