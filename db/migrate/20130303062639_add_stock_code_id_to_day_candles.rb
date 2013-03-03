class AddStockCodeIdToDayCandles < ActiveRecord::Migration
  def change
    add_column :day_candles, :stock_code_id, :integer, :index => true
  end
end
