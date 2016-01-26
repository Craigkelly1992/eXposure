class AddFieldsToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :first_name, :string
    add_column :agencies, :last_name, :string
    add_column :agencies, :company_name, :string
    add_column :agencies, :phone, :string
  end
end
