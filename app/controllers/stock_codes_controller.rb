class StockCodesController < ApplicationController
  def index
    @stock_codes = StockCode.all
  end
end
