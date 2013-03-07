class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.datetime :in_date
      t.string :symbol
      #t.string :brk_nm_kor
      #t.integer :brk_cd

      t.integer :stock_code_id, :index => true
      t.integer :day_candle_id, :index => true
      t.integer :stock_firm_id, :index => true

      t.timestamps
    end
  end
end
