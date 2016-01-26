class DeleteFacebookUrlFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :facebook_url
  end
end
