class AddEnabledToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :enabled, :boolean, default: true
  end
end
