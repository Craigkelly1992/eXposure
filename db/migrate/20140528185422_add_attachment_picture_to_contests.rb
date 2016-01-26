class AddAttachmentPictureToContests < ActiveRecord::Migration
  def self.up
    change_table :contests do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :contests, :picture
  end
end
