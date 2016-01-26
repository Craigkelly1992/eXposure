class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.belongs_to :agency, index: true
      t.string :name
      t.string :facebook
      t.string :twitter
      t.string :instagram
      t.string :slogan
      t.string :website
      t.string :description

      t.timestamps
    end
  end
end
