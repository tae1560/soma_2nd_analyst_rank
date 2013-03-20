class StockFirm < ActiveRecord::Base
  attr_accessible :name, :profit_recent, :profit_1_month, :profit_2_month, :profit_3_month,
                  :profit_4_month, :profit_5_month, :profit_6_month, :profit_7_month,
                  :profit_8_month, :profit_9_month, :profit_10_month, :profit_11_month,
                  :profit_12_month

  has_many :recommendations

  def self.find_or_create_instance id, name
    stock_firm = StockFirm.find_by_id(id)
    unless stock_firm
      stock_firm = StockFirm.new(:name => name)
      stock_firm.id = id
      unless stock_firm.save
        "ERROR : stock_firm did not saved : #{stock_firm.inspect}"
      end
    end
    return stock_firm
  end

  def calculate_profit
    (0..12).each do |month|
      puts "month : #{month}"

      sum_of_profit = 0
      number_of_profit = 0
      #sum_of_start_date = 0
      #sum_of_target_date = 0
      self.recommendations.find_each do |recommendation|
        in_day_candle = recommendation.get_in_day_candle
        out_day_candle = recommendation.get_out_day_candle month
        profit = recommendation.get_profit in_day_candle, out_day_candle

        if profit
          sum_of_profit += profit
          number_of_profit += 1
        end
      end

      if month > 0
        if number_of_profit > 0
          self.send("profit_#{month}_month=", (sum_of_profit / number_of_profit).round(2))
        else
          self.send("profit_#{month}_month=", 0)
        end
      else
        if number_of_profit > 0
          self.profit_recent = (sum_of_profit / number_of_profit).round(2)
        else
          self.profit_recent = 0
        end
      end
    end



    self.save
  end

end
