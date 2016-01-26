namespace :development do
  desc "CREATE ADMIN"
  task :migrate_data => :environment do
    #################
    puts 'CREATING TEST USERS'

    user_count = User.count
    if user_count < 20
      (user_count..20).each do |i|
        u = User.new
        u.email = Faker::Internet.free_email
        u.password = "password"
        u.first_name = Faker::Name.first_name
        u.last_name = Faker::Name.last_name
        u.phone = "(999) 999-9999"
        u.username = Faker::Internet.user_name
        u.profile_picture = File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")
        u.background_picture = File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")
        u.enabled = true
        u.save!
        puts "#{i}/20 complete"
      end
    end

    ##########
    puts "FOLLOWING EACH OTHER"
    users = User.all
    users.each do |user|
      users.each do |u|
        user.follow u if rand(2) == 1
      end
    end



    ###################
    puts 'CREATING TEST AGENCIES'

    agency_count = Agency.count
    if agency_count < 5
      (agency_count..5).each do |i|
        u = Agency.new
        u.email = Faker::Internet.free_email
        u.password = "password"
        u.first_name = Faker::Name.first_name
        u.last_name = Faker::Name.last_name
        u.phone = "(999) 999-9999"
        u.company_name = Faker::Company.name
        u.save!
        puts "#{i}/20 complete"
      end
    end

    ######
    puts 'CREATING BRANDS'

    brand_count = Brand.count

    if brand_count < 20
      (brand_count..20).each do |i|
        b = Brand.new
        b.agency_id = Agency.offset(rand(Agency.count)).first.id
        b.name = Faker::Company.name
        b.facebook = "http://facebook.com/"
        b.twitter = Faker::Internet.user_name
        b.instagram = Faker::Internet.user_name
        b.slogan = Faker::Company.catch_phrase
        b.website = "http://mybrand.com"
        b.description = Faker::Lorem.paragraph
        b.photos.build([{:picture => File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")},
                        {:picture => File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")}])
        b.save!
        puts "#{i}/20 complete"
      end
    end

    #######
    puts 'CREATING CONTESTS'
    contest_count = Contest.count
    if contest_count < 10
      (contest_count..10).each do |i|
        c = Contest.new
        c.brand_id = Agency.offset(rand(Agency.count)).first.id
        c.title = Faker::Company.catch_phrase
        c.description = Faker::Lorem.paragraph
        c.rules = Faker::Lorem.paragraph
        c.prizes = Faker::Lorem.paragraph
        c.voting = contest_count.odd?
        c.start_date = Time.now
        c.end_date = Time.now + 15.days
        c.picture = File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")
        c.save!
        puts "#{i}/10 complete"
      end
    end

    ######################

    puts 'CREATING POSTS WITHIN CONTESTS'

    post_count = Post.where("contest_id IS NOT NULL").count

    if post_count < 50
      (post_count..50).each do |i|
        p = Post.new
        p.uploader_id = loop do
          offset=User.offset(rand(User.count)).first.id
          break offset
        end
        p.contest_id = loop do
          offset=User.offset(rand(User.count)).first.id
          break offset
        end
        p.image = File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")
        p.text = Faker::Lorem.sentence
        p.save!
        puts "#{i}/50 complete"
      end
    end

    puts 'CREATING POSTS WITHOUT CONTESTS'

    post_count = Post.where(contest_id: nil).count

    if post_count < 20
      (post_count..20).each do |i|
        p = Post.new
        p.uploader_id = loop do
          offset=User.offset(rand(User.count)).first.id
          break offset
        end
        p.image = File.new("#{Rails.root}/test/sample_photos/art_#{i}.jpg")
        p.text = Faker::Lorem.sentence
        p.save!
        puts "#{i}/20 complete"
      end

    end


    ##################
    posts=Post.all
    puts 'CREATING COMMENTS'
    if Comment.count == 0
      posts.each do |post|
        users.each do |user|
          post.comments.create(user_id: user.id, post_id: post.id, text: Faker::Lorem.sentence) if rand(2) == 1
        end
      end
    end

    ################
    puts "CREATING LIKES"

    posts.each do |p|
      users.each do |u|
        u.likes p if rand(2) == 1
      end
    end

    ###################
    puts "FOLLOWING BRANDS"

    brands=Brand.all
    brands.each do |b|
      users.each do |u|
        u.follow b if rand(2) == 1
      end
    end
  end
end