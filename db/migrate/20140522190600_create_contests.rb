class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.belongs_to :brand, index: true
      t.string :title
      t.string :description
      t.string :rules
      t.string :prizes
      t.boolean :voting
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
