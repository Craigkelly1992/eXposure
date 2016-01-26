class FinishContestWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"
  sidekiq_options retry: false, :queue => :finish_contest

  def perform(contest_id)
    contest=Contest.find(contest_id)
    if contest.jid
      queue = Sidekiq::Queue.new("finish_contest")
      queue.each do |job|
        job.delete if job.jid == contest.jid
      end
    end
    Winner.create(contest_id: contest.id, user_id: contest.posts.order(cached_votes_up: :desc).first.user.id)
  end

end