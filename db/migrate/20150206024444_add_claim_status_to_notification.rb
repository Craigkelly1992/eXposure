class AddClaimStatusToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :is_claimed, :boolean, :default => false
  end
end
