class StockFirmsController < ApplicationController
  def index
    @stock_firms = StockFirm.all
  end

  def show
    @stock_firm = StockFirm.find(params[:id])
  end
end
