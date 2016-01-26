class AddContestIdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :contest_id, :integer
  end
end
