module StockFirmsHelper
  def class_of_profit profit
    if profit and profit != "-" and profit.to_f < 0
      return "down"
    else
      return "up"
    end

  end

  def class_of_risk risk
    if risk and risk != "-" and risk.to_f < 10
      return "down"
    else
      return "up"
    end
  end
end
