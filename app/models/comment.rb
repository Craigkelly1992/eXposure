class Comment < ActiveRecord::Base
  self.per_page = 18
  belongs_to :post
  belongs_to :user
  after_create :notify_comment

  private

  def notify_comment

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

        #NotificationsMailer.winner(self.id).deliver!
        APNS.send_notification(device_token, :alert => self.text, :badge => 1, :sound => 'default')

      end

    rescue => e

      logger.warn "Apple pushed notification, will ignore: #{e}"

    end

  end


end
