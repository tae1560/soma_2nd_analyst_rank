class AddProfitToStockFirms < ActiveRecord::Migration
  def change
    add_column :stock_firms, :profit_recent, :float
    add_column :stock_firms, :profit_1_month, :float
    add_column :stock_firms, :profit_2_month, :float
    add_column :stock_firms, :profit_3_month, :float
    add_column :stock_firms, :profit_4_month, :float
    add_column :stock_firms, :profit_5_month, :float
    add_column :stock_firms, :profit_6_month, :float
    add_column :stock_firms, :profit_7_month, :float
    add_column :stock_firms, :profit_8_month, :float
    add_column :stock_firms, :profit_9_month, :float
    add_column :stock_firms, :profit_10_month, :float
    add_column :stock_firms, :profit_11_month, :float
    add_column :stock_firms, :profit_12_month, :float
  end
end
