class Recommendation < ActiveRecord::Base
  attr_accessible :in_date, :symbol, :mongo_id, :reason_in

  belongs_to :stock_code
  belongs_to :day_candle
  belongs_to :stock_firm

  has_one :raw_recommendation

  def get_profit_or_recent keep_period, loss_cut = -1
    in_day_candle = self.get_in_day_candle
    out_day_candle = self.get_out_day_candle keep_period, loss_cut

    unless out_day_candle
      out_day_candle = DayCandle.where(:symbol => self.symbol).order(:trading_date).last
    end

    return get_profit_with_day_candle in_day_candle, out_day_candle
  end

  def get_profit keep_period, loss_cut = -1
    in_day_candle = self.get_in_day_candle
    out_day_candle = self.get_out_day_candle keep_period, loss_cut

    return get_profit_with_day_candle in_day_candle, out_day_candle
  end

  def get_profit_with_day_candle in_day_candle, out_day_candle
    profit = nil
    if in_day_candle and out_day_candle and in_day_candle.open != 0
      profit = ((out_day_candle.close - in_day_candle.open) / in_day_candle.open.to_f * 100).round(2)
    end
    return profit
  end

  def get_out_day_candle keep_period, loss_cut = -1
    # keep_period with days
    out_day_candle = nil
    if keep_period
      base_date = self.in_date + keep_period
      out_day_candle = DayCandle.where("trading_date > '#{base_date}'").where(:symbol => self.symbol).order(:trading_date).first
    end

    unless out_day_candle
      #out_day_candle = DayCandle.where(:symbol => self.symbol).order(:trading_date).last
    end

    if loss_cut < 0
      return out_day_candle
    else
      #  loss_cut에 해당하는 out_day_candle 찾기
      in_day_candle = self.get_in_day_candle
      day_candles = nil
      if in_day_candle and out_day_candle
        day_candles = DayCandle.where(:symbol => self.symbol).where("trading_date > '#{in_day_candle.trading_date}' AND trading_date < '#{out_day_candle.trading_date}'")
      elsif in_day_candle
        day_candles = DayCandle.where(:symbol => self.symbol).where("trading_date > '#{in_day_candle.trading_date}'")
      end

      if in_day_candle
        if day_candles.where("open < '#{in_day_candle.open * (100 - loss_cut) * 0.01}'").count > 0
          return day_candles.where("open < '#{in_day_candle.open * (100 - loss_cut) * 0.01}'").order(:trading_date).first
        end
      end

      if day_candles and loss_cut
        day_candles.order(:trading_date).find_each do |day_candle|
          profit = get_profit_with_day_candle(in_day_candle, day_candle)
          if profit and profit < -loss_cut
            # loss_cut 적용시
            return day_candle
          end
        end
      end

      return out_day_candle
    end
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
