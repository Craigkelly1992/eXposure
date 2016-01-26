class Post < ActiveRecord::Base
  self.per_page = 18
  belongs_to :user, foreign_key: "uploader_id"
  belongs_to :contest
  has_many :comments, dependent: :destroy
  before_save :decode_image_data
  acts_as_votable
  attr_accessor :image_data
  has_attached_file :image,
                    storage: :s3,
                    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
                    :styles => { preview: "600x600^", square: "600x600^", thumb: "100x100^" },
                    :default_url => lambda { |image| ActionController::Base.helpers.asset_path('ph.jpg') }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/, presence: true
  
  def image_url
    self.image.url
  end

  def image_url_thumb
    self.image.url(:thumb)
  end

  def image_url_preview
    self.image.url(:preview)
  end

  def image_url_square
    self.image.url(:square)
  end

  def current_user_likes
    User.current.liked?(self) if User.current
  end

  def brand
    if self.contest
      self.contest.brand.id
    end
  end

  def selected
    self.update_attributes(is_selected: true)
  end

  private

  def decode_image_data
    # If image_data is present, it means that we were sent an image over
    # JSON and it needs to be decoded.  After decoding, the image is processed
    # normally via Paperclip.
    if self.image_data.present?
        data = StringIO.new(Base64.decode64(self.image_data))
        data.class.class_eval {attr_accessor :original_filename, :content_type}
        data.original_filename = "photo"
        data.content_type = "image/jpg"
        self.image = data
    end
  end

end
