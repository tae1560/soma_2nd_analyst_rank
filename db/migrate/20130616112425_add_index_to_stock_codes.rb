class AddIndexToStockCodes < ActiveRecord::Migration
  def change
    add_index :stock_codes, :symbol, :unique => true
  end
end
