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
      return ((out_day_candle.close - in_day_candle.close) / in_day_candle.close.to_f * 100)
    else
      return 0
    end
  end

  def get_profit in_day_candle, out_day_candle
    profit = nil
    if in_day_candle and out_day_candle and in_day_candle.open != 0
      profit = ((out_day_candle.close - in_day_candle.open) / in_day_candle.open.to_f * 100).round(2)
    end
    return profit
  end

  def get_out_day_candle base_date_type
  #  1~12 : in_date + month // 0 : now
    out_day_candle = nil
    if base_date_type and base_date_type.to_i > 0
      base_date = self.in_date + base_date_type.to_i.months
      out_day_candle = DayCandle.where("trading_date > '#{base_date}'").where(:symbol => self.symbol).order(:trading_date).first
    end

    unless out_day_candle
      #out_day_candle = DayCandle.where(:symbol => self.symbol).order(:trading_date).last
    end

    return out_day_candle
  end

  def get_in_day_candle
    DayCandle.where("trading_date > '#{self.in_date}'").where(:symbol => self.symbol).order(:trading_date).first
  end
end
