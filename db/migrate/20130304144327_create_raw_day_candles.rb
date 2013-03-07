class CreateRawDayCandles < ActiveRecord::Migration
  def change
    create_table :raw_day_candles do |t|
      t.datetime :date
      t.integer :o
      t.integer :h
      t.integer :l
      t.integer :c
      t.integer :v
      t.string :symbol

      t.integer :day_candle_id, :index => true

      t.timestamps
    end

    add_index :raw_day_candles, [:symbol, :date], :unique => true
  end
end
