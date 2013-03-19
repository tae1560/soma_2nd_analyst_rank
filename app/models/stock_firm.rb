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
    puts "recent"
    sum_of_profit = 0
    number_of_profit = 0
    self.recommendations.find_each do |recommendation|
      sum_of_profit += recommendation.profit Time.now
      number_of_profit += 1
    end

    if number_of_profit > 0
      self.profit_recent = (sum_of_profit / number_of_profit).round(2)
    else
      self.profit_recent = 0
    end

    (1..12).each do |month|
      puts "month : #{month}"
      sum_of_profit = 0
      number_of_profit = 0
      #sum_of_start_date = 0
      #sum_of_target_date = 0
      self.recommendations.find_each do |recommendation|
        target_date = recommendation.in_date + month.months
        if target_date < Time.now
          sum_of_profit += recommendation.profit recommendation.in_date + month.months
          number_of_profit += 1

          #out_date = out_date.to_date.to_datetime - 9.hours
          #sum_of_start_date = 0
          #sum_of_target_date = 0
        end
      end

      if number_of_profit > 0
        self.send("profit_#{month}_month=", (sum_of_profit / number_of_profit).round(2))
      else
        self.send("profit_#{month}_month=", 0)
      end
    end



    self.save
  end

end
