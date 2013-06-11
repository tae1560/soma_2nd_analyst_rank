class AddLinkToMongoColumns < ActiveRecord::Migration
  def change
    add_column :stock_codes, :mongo_id, :string
    add_column :day_candles, :mongo_id, :string
    add_column :recommendations, :mongo_id, :string
    add_column :stock_firms, :mongo_id, :string
  end
end
