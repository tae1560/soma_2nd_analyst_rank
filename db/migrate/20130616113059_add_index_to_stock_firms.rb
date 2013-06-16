class AddIndexToStockFirms < ActiveRecord::Migration
  def change
    add_index :stock_firms, :name, :unique => true

    #stock_code : index({ symbol: 1}, { unique: true })
    #day_candle : index({ symbol: 1, trading_date: 1}, { unique: true })
    #stock_firm : index({ name: 1}, { unique: true })
    #recommendation : index({ stock_code_id: 1, stock_firm_id: 1, in_date: 1, symbol: 1}, { unique: true })
    #keep/recent period : index({ name: 1, days: 1}, { unique: true })
    #loss_cut : percent
  end
end
