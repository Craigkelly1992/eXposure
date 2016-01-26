class AddCachedScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cached_score, :integer, default: 0
  end
end
