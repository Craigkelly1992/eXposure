class API::ContestsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!, except: [:index, :show, :by_brand]
  respond_to :json

  def index
    user = User.find(params[:user_id])
    following = user.all_following.map{ |f| f.id }
    current_time = Time.now.in_time_zone.utc
    if following.length == 0
      @contests = Contest.all.where('end_date > ? and start_date < ?', current_time, current_time)
                         .paginate(page: params[:page]).order(start_date: :desc)
    else
      @contests = Contest.all.where('(end_date > ? and start_date < ?) OR (end_date > ? and brand_id IN (?))', current_time, current_time, current_time, following)
                             .paginate(page: params[:page]).order(start_date: :desc)
    end

    respond_with @contests, only: [:id, :brand_id, :title, :description, :rules, :prizes, :start_date, :end_date, :location, :latitude, :longitude, :winner_id],
                            methods: [:brand_name, :picture_url, :picture_url_preview, :picture_url_square, :picture_url_thumb, :current_date_server],
                            location: "/"
  end

  def show
    @contest = Contest.find(params[:id])
    @brand = @contest.brand
    if current_user
      @submissions = @contest.submissions.paginate(page: params[:page]).order(created_at: :desc).map do |s|
        {id: s.id,
        contest_id: s.contest_id,
        uploader_id: s.uploader_id,
        text: s.text,
        cached_votes_up: s.cached_votes_up,
        image_url: s.image_url,
        image_url_square: s.image_url_square,
        image_url_preview: s.image_url_preview,
        image_url_thumb: s.image_url_thumb,
        brand: s.brand,
        current_user_likes: s.current_user_likes
        }
      end
    else
      @submissions = @contest.submissions.paginate(page: params[:page]).order(created_at: :desc).map do |s|
        { id: s.id,
          contest_id: s.contest_id,
          uploader_id: s.uploader_id,
          text: s.text,
          cached_votes_up: s.cached_votes_up,
          image_url: s.image_url,
          image_url_square: s.image_url_square,
          image_url_preview: s.image_url_preview,
          image_url_thumb: s.image_url_thumb,
          brand: s.brand
        }
      end
    end
    json = @contest.as_json()
    json[:current_date_server] = Time.now.in_time_zone
    date_end = json['end_date']
    #json.delete('end_date')
    json[:end_date_text] = date_end.strftime("%I:%M %p - %a %B %d, %Y") unless date_end.blank?
    hash = {contest: {status: @contest.status, info: json},
            brand: @brand, submissions: {count: @submissions.count, submissions: @submissions},
            winners: @contest.winners}
    impressionist(@contest, "contest")
    respond_with hash, location: '/'
  end

  def by_following
    @user = User.find(params[:user_id])
    @following = @user.all_following.map{ |f| f.id }
    @contests = Contest.where(brand_id: @following)
                       .where('end_date > ?', Time.now.in_time_zone).order(start_date: :desc)
    respond_with @contests, methods: [:brand_name, :picture_url, :picture_url_preview, :picture_url_square, :picture_url_thumb], location: "/"
  end

  def by_brand
    @contests = Contest.where('brand_id = ? AND end_date > ?',params[:brand_id], Time.now.in_time_zone)
                       .paginate(page: params[:page]).order(start_date: :desc)
    respond_with @contests, methods: [:brand_name, :picture_url, :picture_url_preview, :picture_url_square, :picture_url_thumb], location: "/"
  end

  def claim_prize
    @contest = Contest.find(params[:id])
    @user = current_user
    if @user.won?(@contest)
      w = params[:winner]
      winner = OpenStruct.new(
        first_name: w[:first_name],
        last_name: w[:last_name],
        email: w[:email],
        phone: w[:phone],
        street: w[:street],
        city: w[:city],
        province: w[:province],
        postal_code: w[:postal_code]
      )
      NotificationsMailer.contact_agency(@contest, @user, winner).deliver!

      notification = Notification.find(params[:notification_id])
      unless notification.nil?
        notification.claimed
        post = Post.find(notification.post_id)
        winner = User.find(notification.receiver_id)
        sender = Agency.find(notification.sender_id)
        NotificationsMailer.winner(notification,post,winner,sender).deliver!
      end

      json = {status: "sent", winner: winner}.to_json
      respond_with json, location: '/'
    else
      error = {error: "this user have not won the contest"}.to_json
      respond_with error, status: :unprocessable_entity, location: "/"
    end
  end

end