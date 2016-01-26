class AddWinnerIdToContests < ActiveRecord::Migration
  def change
    add_column :contests, :winner_id, :integer
  end
end
