class CreateStockFirms < ActiveRecord::Migration
  def change
    create_table :stock_firms do |t|
      t.string :name

      t.timestamps
    end
  end
end
