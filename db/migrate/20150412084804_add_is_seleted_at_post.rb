class AddIsSeletedAtPost < ActiveRecord::Migration
  def change
    add_column :posts, :is_selected, :boolean, :default => false
  end
end
