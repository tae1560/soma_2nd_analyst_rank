class CreateDayCandles < ActiveRecord::Migration
  def change
    create_table :day_candles do |t|
      #attr_accessible :symbol, :date, :o, :h, :l, :c, :v, :trading_date, :crawl_date

      t.string :symbol, :presence => true
      #t.string :date, :presence => true
      t.datetime :trading_date, :presence => true
      t.integer :open
      t.integer :high
      t.integer :low
      t.integer :close
      t.integer :volume
      #t.datetime :crawl_date

      t.integer :stock_code_id, :index => true

      t.timestamps
    end

    add_index :day_candles, [:symbol, :trading_date], :unique => true


  end
end
