class AddAttachmentImageToNotifications < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :notifications, :image
  end
end
