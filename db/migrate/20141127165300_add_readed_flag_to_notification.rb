class AddReadedFlagToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :readed_flag, :boolean, :default => false
  end
end
