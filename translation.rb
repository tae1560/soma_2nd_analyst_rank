table "analyses" do
  column "id", :key, :as => :integer
  column "earning_average", :float
  column "earning_variance", :float
  column "stock_firm_id", :integer, :references => "stock_firms"
  column "created_at", :datetime
  column "updated_at", :datetime
  column "keep_period_id", :integer, :references => "keep_periods"
  column "recent_period_id", :integer, :references => "recent_periods"
  column "loss_cut_id", :integer, :references => "loss_cuts"
  column "count_winner", :integer
  column "count_loser", :integer
end

table "day_candles" do
  column "id", :key, :as => :integer
  column "symbol", :string
  column "trading_date", :datetime
  column "open", :integer
  column "high", :integer
  column "low", :integer
  column "close", :integer
  column "volume", :integer
  column "stock_code_id", :integer, :references => "stock_codes"
  column "created_at", :datetime
  column "updated_at", :datetime
end

table "keep_periods" do
	column "id", :key, :as => :integer
	column "name", :string
	column "days", :integer
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "loss_cuts" do
	column "id", :key, :as => :integer
	column "percent", :float
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "recent_periods" do
	column "id", :key, :as => :integer
	column "name", :string
	column "days", :integer
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "recommendations" do
	column "id", :key, :as => :integer
	column "in_date", :datetime
	column "symbol", :string
	column "stock_code_id", :integer, :references => "stock_codes"
	column "day_candle_id", :integer, :references => "day_candles"
	column "stock_firm_id", :integer, :references => "stock_firms"
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "schema_migrations" do
	column "version", :string
end

table "stock_codes" do
	column "id", :key, :as => :integer
	column "name", :string
	column "eng_name", :string
	column "symbol", :string
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "stock_firms" do
	column "id", :key, :as => :integer
	column "name", :string
	column "created_at", :datetime
	column "updated_at", :datetime
end
