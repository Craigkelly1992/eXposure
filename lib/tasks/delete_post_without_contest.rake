namespace :development do
  task :delete_post_without_contest => :environment do
    Post.where('contest_id = ? OR contest_id = ?',nil,'').each do |post|
      post.delete
    end
  end
end