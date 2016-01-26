class AddCachedViewsToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :cached_views, :integer, :default => 0
  end
end
