module ApplicationHelper

  def comment_response_with_include_user_avatar_url(comments)
    com = []
    comments.each do |comment|
      tmp_hash = comment.as_json()
      tmp_hash[:user_avatar_url] = comment.user.profile_picture_url_thumb
      com << tmp_hash
    end
    com
  end
  
  def render_post_with_include_comments(post)
    {
      id: post.id,
      contest_id: post.contest_id,
      uploader_id: post.uploader_id,
      text: post.text,
      cached_votes_up: post.cached_votes_up,
      created_at: post.created_at,
      uploader_avatar: post.user.profile_picture_url_thumb,
      image_url: post.image_url,
      image_url_square: post.image_url_square,
      image_url_preview: post.image_url_preview,
      image_url_thumb: post.image_url_thumb,
      brand: post.brand, 
      comments: comment_response_with_include_user_avatar_url(post.comments)
    }
    
  end

  def render_user_json_with_status(user)
    {
      is_error: false,
      error_description: "User was created.",
      user:
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        username: user.username,
        phone: user.phone,
        authentication_token: user.authentication_token,
        description: user.description,
        facebook: user.facebook,
        twitter: user.twitter,
        instagram: user.instagram,
        profile_picture_url: user.profile_picture_url,
        profile_picture_url_thumb: user.profile_picture_url_thumb,
        profile_picture_url_preview: user.profile_picture_url_preview,
        profile_picture_url_square: user.profile_picture_url_square,
        background_picture_url: user.background_picture_url,
        background_picture_url_preview: user.background_picture_url_preview,
        posts: user.posts,
        follow_count: user.follow_count,
        followers_count: user.followers_count
      }
    }
  end

end
