module StockFirmsHelper
  def class_of_profit profit
    if profit < 0
      return "text-error"
    else
      return "text-success"
    end

  end
end
