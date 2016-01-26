namespace :development do
  task :migrate_old_brand_data => :environment do
    Brand.where('created_at < ?','2014-12-03').each do |brand|
      next if brand.picture_file_name.blank?
      brand.photos.build(picture: brand.picture)
      brand.picture_file_name = ""
      brand.save
    end
  end
end