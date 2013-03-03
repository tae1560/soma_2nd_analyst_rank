class CreateStockCodes < ActiveRecord::Migration
  def change
    create_table :stock_codes do |t|
      #institution_code, name, eng_name, standard_code, short_code, market_type, symbol

      t.string :institution_code
      t.string :name, :presence => true
      t.string :eng_name
      t.string :standard_code
      t.string :short_code
      t.string :market_type
      t.string :symbol, :unique => true, :index => true

      t.timestamps
    end
  end
end
