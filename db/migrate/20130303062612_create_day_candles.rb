class CreateDayCandles < ActiveRecord::Migration
  def change
    create_table :day_candles do |t|
      #attr_accessible :symbol, :date, :o, :h, :l, :c, :v, :trading_date, :crawl_date

      t.string :symbol, :presence => true
      #t.string :date, :presence => true
      t.datetime :trading_date, :presence => true
      t.integer :o
      t.integer :h
      t.integer :l
      t.integer :c
      t.integer :v
      t.datetime :crawl_date

      t.timestamps
    end

    add_index :day_candles, [:symbol, :trading_date], :unique => true
  end
end
