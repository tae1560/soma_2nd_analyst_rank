class StockFirm < ActiveRecord::Base
  attr_accessible :name

  has_many :recommendations
  has_many :analyses

  has_many :users, :through => :user_favorite_stock_firms

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
    KeepPeriod.find_each do |keep_period|
      RecentPeriod.find_each do |recent_period|
        analysis = self.analyses.where(:keep_period_id => keep_period.id, :recent_period_id => recent_period.id).first
        unless analysis
          analysis = Analysis.create
          analysis.keep_period = keep_period
          analysis.recent_period = recent_period
          self.analyses << analysis
        end

        puts "stock_firm : #{analysis.stock_firm.name} keep : #{analysis.keep_period.name}, recent : #{analysis.recent_period.name}"

        # start calculate
        profit_array = []

        # recent_period
        filtered_recommendations = nil
        if analysis.recent_period.days < 0
          filtered_recommendations = self.recommendations
        else
          filtered_recommendations = self.recommendations.where("in_date > '#{Time.now - analysis.recent_period.days.days}'")
        end

        filtered_recommendations.find_each do |recommendation|
          in_day_candle = recommendation.get_in_day_candle
          # keep_period
          out_day_candle = recommendation.get_out_day_candle analysis.keep_period.days.days
          profit = recommendation.get_profit in_day_candle, out_day_candle

          if profit
            profit_array.push profit
          end
        end

        # calculate average and variance
        sum_of_profit = 0
        profit_array.each do |profit|
          sum_of_profit += profit
        end

        earning_average = nil
        if profit_array.size > 0
          earning_average = sum_of_profit / profit_array.size
        end

        if earning_average
          sum_of_profit_for_variance = 0
          profit_array.each do |profit|
            sum_of_profit_for_variance += ((profit - earning_average) * (profit - earning_average))
          end

          analysis.earning_average = earning_average
          analysis.earning_variance = sum_of_profit_for_variance / profit_array.size
          analysis.save
        end
      end
    end

    return

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
