class CreateRawStockCodes < ActiveRecord::Migration
  def change
    create_table :raw_stock_codes do |t|
      t.string :institution_code
      t.string :name
      t.string :eng_name
      t.string :standard_code, :index => true, :unique => true
      t.string :short_code
      t.string :market_type

      t.integer :stock_code_id, :index => true

      t.timestamps
    end
  end
end
