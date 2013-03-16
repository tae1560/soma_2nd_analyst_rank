class StockFirm < ActiveRecord::Base
  attr_accessible :name

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
    sum_of_profit = 0
    self.recommendations.find_each do |recommendation|
      sum_of_profit += recommendation.profit Time.now
    end
    self.profit = sum_of_profit.round(2)
    self.save
  end

end
