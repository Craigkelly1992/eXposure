class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.string :token
      t.string :token_secret
      t.datetime :token_expires_at
      t.string :uid
      t.string :username
      t.string :profile_url
      t.string :profile_picture

      t.timestamps
    end
  end
end
