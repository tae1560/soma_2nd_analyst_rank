class Recommendation < ActiveRecord::Base
  attr_accessible :in_date, :symbol

  belongs_to :stock_code
  belongs_to :day_candle
  belongs_to :stock_firm
  belongs_to :loss_cut

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

  def get_out_day_candle keep_period
  # keep_period with days
    out_day_candle = nil
    if keep_period
      base_date = self.in_date + keep_period
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

  def get_mdd_with_day_candle in_day_candle, out_day_candle
    if in_day_candle and out_day_candle
      day_candles = DayCandle.where(:symbol => self.symbol).where("trading_date > '#{in_day_candle.trading_date}' AND trading_date < '#{out_day_candle.trading_date}'")

      low = nil
      high = nil
      day_candles.each do |day_candle|
        if low == nil or low > day_candle.low
          low = day_candle.low
        end

        if high == nil or high < day_candle.high
          high = day_candle.high
        end
      end

      return [low, high]
    else
      return nil
    end
  end

  def get_mdd keep_period
    in_day_candle = self.get_in_day_candle
    # keep_period
    out_day_candle = self.get_out_day_candle keep_period

    get_mdd_with_day_candle in_day_candle, out_day_candle
  end
end
