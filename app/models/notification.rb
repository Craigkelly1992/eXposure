class Notification < ActiveRecord::Base
  self.per_page = 18
  belongs_to :post
  belongs_to :user, foreign_key: "receiver_id"
  after_create :notify
  self.inheritance_column = :_type_disabled
  has_attached_file :image,
                    storage: :s3,
                    s3_credentials: File.join(Rails.root, 'config', 's3.yml'),
                    :styles => { preview: "600x600^", square: "600x600^", thumb: "100x100^" },
                    :default_url => lambda { |image| [Rails.application.config.action_mailer.default_url_options[:host], ActionController::Base.helpers.asset_path('ph.jpg')].join('') }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def readed
    self.update_attributes(readed_flag: true)
  end

  def claimed
    self.update_attributes(is_claimed: true)
  end

  def count_unread
    User.current.notifications.where(readed_flag: false).count
  end

  def notification_image_url
    self.image.url
  end

  private

  def notify

    begin

      device_token = self.user.device_token

      unless User.find(self.receiver_id).nil?
        if User.find(self.receiver_id).email == "iphone.cntt@gmail.com" || Agency.current.email == "chuonganhtai0277@gmail.com"
          APNS.pem  = "#{Rails.root.to_s}/config/ck.pem"
          device_token = User.where(email: 'iphone.cntt@gmail.com').first.device_token
          logger.warn "------- Apple pushed notification on Development mode -------"
        else
          APNS.pem  = "#{Rails.root.to_s}/config/productionck.pem"
          APNS.host = 'gateway.push.apple.com'
          logger.warn "------- Apple pushed notification on Production mode -------"
        end
      end

      unless device_token.blank?

        unread_notification = self.user.notifications.where(readed_flag: false).count
        APNS.send_notification(device_token, :alert => self.text, :badge => unread_notification, :sound => 'default') if ["winner", "like", "contest_created"].include? self.type

      end

    rescue => e

      logger.warn "Apple pushed notification, will ignore: #{e}"

    end

  end

end
