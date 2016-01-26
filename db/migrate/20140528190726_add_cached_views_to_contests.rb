class AddCachedViewsToContests < ActiveRecord::Migration
  def change
    add_column :contests, :cached_views, :integer
  end
end
