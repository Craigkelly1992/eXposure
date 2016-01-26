class AddAttachmentBackgroundPictureToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :background_picture
    end
  end

  def self.down
    drop_attached_file :users, :background_picture
  end
end
