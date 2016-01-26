class Contest < ActiveRecord::Base
  self.per_page = 18
  has_many :posts, dependent: :destroy
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :start_date_over_end_date
  # has_many :winners
  belongs_to :brand
  is_impressionable :counter_cache => true, :column_name => :cached_views, :unique => :request_hash

  has_attached_file :picture,
                    storage: :s3,
                    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
                    :styles => { preview: "600x600^", square: "600x600^", thumb: "100x100^" },
                    :default_url => lambda { |image| ActionController::Base.helpers.asset_path('ph.jpg') }
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/, presence: true

  after_create :notify_followers

  def submissions_count(scope=:all)
    self.submissions(scope).count
  end

  def winners
    User.where("id in (select user_id from winners where contest_id = ?)", self.id)
  end

  def brand_name
    self.brand.name
  end

  def picture_url
    self.picture.url
  end

  def picture_url_square
    self.picture.url(:square)
  end

  def picture_url_preview
    self.picture.url(:preview)
  end

  def picture_url_thumb
    self.picture.url(:thumb)
  end

  def current_date_server
    Time.now
  end

  def submissions(scope=:all)
    if scope == :all
      self.posts.order(cached_votes_total: :desc)
    elsif scope == :today
      self.posts.where("created_at > ?", Time.now.at_beginning_of_day).order(cached_votes_total: :desc)
    end
  end

  def status
    if self.end_date && self.end_date > Time.now && self.start_date < Time.now
      "OPEN"
    else
      "CLOSE"
    end
  end

  def start_date_over_end_date
    if start_date > end_date
      errors.add(:start_date, "can't be over the end date")
    end
  end

  private

  def notify_followers
    PushNotificationsWorker.perform_async(self.brand.id, self.id)
  end

end
