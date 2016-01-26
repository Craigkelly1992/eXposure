class NotificationsMailer < ActionMailer::Base
  default from: "contests@exposuretechnologies.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.winner.subject
  #
  def winner(notification,post,winner,sender)
    @post = post
    @contest= @post.contest
    @brand = @contest.brand
    @greeting = "Hi"
    @winner = winner
    @message = notification.text
    @sender = sender
    mail to: @winner.email, subject: "You were selected as a winner by #{@brand.name}!"
  end

  def like(recipient_id,sender_id,notification_id,post_id)
  end
  def follow(recipient_id,sender_id,notification_id)
  end
  def comment(recipient_id,sender_id,notification_id,post_id)
  end

  def contact_agency(contest, user, winner)
    @contest = contest
    @winner = winner
    @agency = @contest.brand.agency
    mail to: @agency.email, subject: "Winner #{@winner.first_name} #{@winner.last_name} is claiming the prize for contest #{@contest.title}"
  end

end
