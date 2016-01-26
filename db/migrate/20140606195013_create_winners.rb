class CreateWinners < ActiveRecord::Migration
  def change
    create_table :winners do |t|
      t.belongs_to :contest, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
