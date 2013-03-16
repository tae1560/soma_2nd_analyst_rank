class Recommendation < ActiveRecord::Base
  attr_accessible :in_date, :symbol

  belongs_to :stock_code
  belongs_to :day_candle
  belongs_to :stock_firm

  def profit out_date
    out_date = out_date.to_date.to_datetime - 9.hours

    out_day_candle = nil
    if out_date
      out_day_candle = DayCandle.where(:trading_date => out_date, :symbol => self.symbol).first
    end

    unless out_day_candle
      out_day_candle = DayCandle.where(:symbol => self.symbol).order(:trading_date).last
    end
    in_day_candle = DayCandle.where(:trading_date => self.in_date, :symbol => self.symbol).first

    if in_day_candle and out_day_candle
      return ((out_day_candle.close - in_day_candle.close) / in_day_candle.close.to_f * 100).round(2)
    else
      return 0
    end
  end
end
