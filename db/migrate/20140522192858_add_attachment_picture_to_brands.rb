class AddAttachmentPictureToBrands < ActiveRecord::Migration
  def self.up
    change_table :brands do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :brands, :picture
  end
end
