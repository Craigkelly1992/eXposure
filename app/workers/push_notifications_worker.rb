class PushNotificationsWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"
  sidekiq_options retry: false, :queue => :push_notifications

  def perform(brand_id, contest_id)
    brand = Brand.find(brand_id)
    contest = Contest.find(contest_id)
    brand.followers.each do |f|
      Notification.create(sender_id: brand.id, receiver_id: f.id, text: "A new contest is up by #{brand.name}", sender_type: "brand", type: "contest_created",
                          sender_picture: brand.picture_url_square, sender_name: brand.name)
    end
  end
end