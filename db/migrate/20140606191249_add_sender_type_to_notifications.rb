class AddSenderTypeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sender_type, :string
  end
end
