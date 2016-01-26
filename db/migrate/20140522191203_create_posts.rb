class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :uploader_id
      t.integer :contest_id
      t.string :text

      t.timestamps
    end
  end
end
