class AddEnabledToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :enabled, :boolean, default: true
  end
end
