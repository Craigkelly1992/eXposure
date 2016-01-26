class API::NotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user_from_token!
  respond_to :json

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    result = {notifications: notifications_with_image_url(@notifications), count_unread: current_user.notifications.where(readed_flag: false).count}
    respond_with result, location: "/"
  end

  def count_unread_notifications
    count_unread = current_user.notifications.where(readed_flag: false).count
    result = {:count_unread => count_unread}
    respond_with result, location: "/"
  end

  def read_notification
    @notification = Notification.find(params[:notification_id])
    @notification.readed
    respond_with @notification, methods: [:notification_image_url], location: "/"
  end

  private

  def notifications_with_image_url(notifications)
    nots = []
    notifications.each do |notify|
      tmp_hash = notify.as_json
      tmp_hash[:notification_image_url] = notify.image.url(:thumb)
      nots << tmp_hash
    end
    nots
  end

end