class CreateStockCodes < ActiveRecord::Migration
  def change
    create_table :stock_codes do |t|
      t.string :name, :presence => true
      t.string :eng_name
      t.string :symbol, :unique => true, :index => true

      t.timestamps
    end
  end
end
