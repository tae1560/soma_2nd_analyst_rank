class DayCandlesController < ApplicationController
  def index
    @day_candles = DayCandle.limit(100)
  end
end
