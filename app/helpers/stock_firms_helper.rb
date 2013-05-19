module StockFirmsHelper
  def class_of_profit profit
    if profit and profit != "-" and profit < 0
      return "stock-down"
    else
      return "stock-up"
    end

  end
end
