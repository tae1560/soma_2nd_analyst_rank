class CreateInvestments < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.datetime :start_date
      t.integer :total_asset
      t.integer :invest_asset

      t.integer :user_id, :index => true
      t.integer :stock_firm_id, :index => true
      t.integer :keep_period_id, :index => true
      t.integer :recent_period_id, :index => true
      t.integer :loss_cut_id, :index => true

      t.timestamps
    end
  end
end
