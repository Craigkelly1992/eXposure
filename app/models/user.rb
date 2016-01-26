class User < ActiveRecord::Base
  self.per_page = 18
	has_many :posts, foreign_key: "uploader_id"
	has_many :providers
	has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy, foreign_key: "receiver_id"
  validates_uniqueness_of :username
  before_save :ensure_authentication_token
  acts_as_followable
  acts_as_follower
  acts_as_voter
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  has_attached_file :profile_picture,
    storage: :s3,
    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
    :styles => { preview: "600x600^", square: "600x600^", thumb: "100x100^" },
    :default_url => lambda { |image| [Rails.application.config.action_mailer.default_url_options[:host], ActionController::Base.helpers.asset_path('ph.jpg')].join('') }
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/, presence: true

  has_attached_file :background_picture,
    storage: :s3,
    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
    :styles => { preview: "600x600^", square: "600x600^" },
    :default_url => lambda { |image| [Rails.application.config.action_mailer.default_url_options[:host], ActionController::Base.helpers.asset_path('ph.jpg')].join('') }
  validates_attachment_content_type :background_picture, :content_type => /\Aimage\/.*\Z/, presence: true

    def ensure_authentication_token
      self.authentication_token = generate_authentication_token if authentication_token.blank?
    end

    def won?(contest)
      return true if Winner.find_by(user_id: self.id, contest_id: contest.id)
    end

    def full_name
      "#{self.first_name} #{self.last_name}"
    end

    def friends

    end

    def contests
      post_ids = posts.pluck(:contest_id)
      Contest.where(id: post_ids)
    end

    def current_user_following
      if User.current.following?(self)
        true
      else
        false
      end
    end

    def profile_picture_url
      self.profile_picture.url
    end

    def profile_picture_url_thumb
      self.profile_picture.url(:thumb)
    end

    def profile_picture_url_preview
      self.profile_picture.url(:preview)
    end

    def profile_picture_url_square
      self.profile_picture.url(:square)
    end

    def background_picture_url
      self.background_picture.url
    end

    def background_picture_url_preview
      self.background_picture.url(:preview)
    end

    def score
      self.posts.sum("cached_votes_up")
    end

    def self.current
      Thread.current[:user]
    end
    def self.current=(user)
      Thread.current[:user] = user
    end

    def timeout_in
      2.seconds
    end

    private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end
end
