class CreateVirtualAssets < ActiveRecord::Migration
  def change
    create_table :virtual_assets do |t|
      t.datetime :date
      t.integer :amount
      t.datetime :last_modified
      t.integer :simulation_id, :index => true
      t.timestamps
    end
  end
end