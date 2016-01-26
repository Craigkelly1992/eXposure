class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :receiver_id
      t.integer :sender_id
      t.string :type
      t.belongs_to :post, index: true
      t.string :text
      t.string :sender_picture
      t.string :sender_name

      t.timestamps
    end
  end
end
