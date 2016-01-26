class AddLocationToContests < ActiveRecord::Migration
  def change
    add_column :contests, :location, :string
    add_column :contests, :latitude, :float
    add_column :contests, :longitude, :float
  end
end
