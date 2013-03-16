class AddProfitToStockFirms < ActiveRecord::Migration
  def change
    add_column :stock_firms, :profit, :float
  end
end
