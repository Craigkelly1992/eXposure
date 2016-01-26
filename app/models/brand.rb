class Brand < ActiveRecord::Base
  self.per_page = 18
  belongs_to :agency
  has_many :contests, dependent: :destroy
  acts_as_followable
  is_impressionable :counter_cache => true, :column_name => :cached_views, :unique => :request_hash
  has_many :photos, :dependent => :destroy
  accepts_nested_attributes_for :photos, :allow_destroy => true
  validates_presence_of :name
  has_attached_file :picture,
      storage: :s3,
      s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
      :styles => { preview: "600x600^", square: "600x600^", thumb: "100x100^" },
      :default_url => lambda { |image| ActionController::Base.helpers.asset_path('ph.jpg') }
  def submissions
    Post.where("contest_id in (select id from contests where brand_id=?)", self.id).order(created_at: :desc)
  end

  def submissions_mobile
    submissions.map do |s|
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
  end
  def submissions_count
    self.submissions.count
  end
  def picture_url
    self.photos[0].picture.url
  end
  def picture_url_square
    self.photos[0].picture_url_square
  end
  def picture_url_preview
    self.photos[0].picture_url_preview
  end
  def picture_url_thumb
    self.photos[0].picture_url_thumb
  end
  def background_url
    self.photos[1].picture.url
  end
  def background_url_square
    self.photos[1].picture_url_square
  end
  def background_url_preview
    self.photos[1].picture_url_preview
  end
  def background_url_thumb
    self.photos[1].picture_url_thumb
  end

  def winners
    w = []
    self.contests.each do |c|
      x = c.winners.map do |u|
        {
          id: u.id,
          email: u.email,
          first_name: u.first_name,
          last_name: u.last_name,
          username: u.username,
          profile_picture_url: u.profile_picture_url,
          profile_picture_url_thumb: u.profile_picture_url_thumb,
          profile_picture_url_preview: u.profile_picture_url_preview,
          profile_picture_url_square: u.profile_picture_url_square,
          background_picture_url: u.background_picture_url,
          background_picture_url_preview: u.background_picture_url_preview
        }
      end
      w += x unless x.nil?
    end
    w
  end

  def followers_list
    self.followers.map do |u|
      {
          id: u.id,
          email: u.email,
          first_name: u.first_name,
          last_name: u.last_name,
          username: u.username,
          profile_picture_url: u.profile_picture_url,
          profile_picture_url_thumb: u.profile_picture_url_thumb,
          profile_picture_url_preview: u.profile_picture_url_preview,
          profile_picture_url_square: u.profile_picture_url_square,
          background_picture_url: u.background_picture_url,
          background_picture_url_preview: u.background_picture_url_preview
        }
    end
  end

  def winners_count
    a = 0
    contests.each do |c|
      a += c.winners.count
    end
    a
  end

  def link_clicks(target)
    self.impressionist_count(message: target, :filter=>:all)
  end

end
