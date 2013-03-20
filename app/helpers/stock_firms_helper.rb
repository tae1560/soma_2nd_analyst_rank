module StockFirmsHelper
  def class_of_profit profit
    if profit and profit != "-" and profit < 0
      return "text-error"
    else
      return "text-success"
    end

  end
end
