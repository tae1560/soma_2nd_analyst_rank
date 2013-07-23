class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.integer :total_asset
      t.integer :invest_asset
      t.datetime  :last_modified
      t.integer :balance_asset
      t.integer :virtual_asset

      t.integer :stock_firm_id, :index => true
      t.integer :recent_period_id, :index => true
      t.integer :keep_period_id, :index => true
      t.integer :loss_cut_id, :index => true


      t.timestamps
    end
  end
end
