class Photo < ActiveRecord::Base

  belongs_to :brand

  has_attached_file :picture,
      storage: :s3,
      s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
      :styles => { preview: "600x600^", square: "600x600^", thumb: "100x100^" },
      :default_url => lambda { |image| ActionController::Base.helpers.asset_path('ph.jpg') }
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/, presence: true
  validates_attachment :picture, presence: true

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

end
