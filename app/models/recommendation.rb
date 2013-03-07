class Recommendation < ActiveRecord::Base
  attr_accessible :in_date, :symbol

  belongs_to :stock_code
  belongs_to :day_candle
  belongs_to :stock_firm
end
