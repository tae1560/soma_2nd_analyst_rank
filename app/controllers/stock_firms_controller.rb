#coding:utf-8
class StockFirmsController < ApplicationController
  def index
    @stock_firms = StockFirm.all
    @stock_firms_rows = []

    unless session[:base_date]
      session[:base_date] = "1"
    end

    if params[:base_date] and params[:base_date].to_i <= 12 and params[:base_date].to_i >= 0
      session[:base_date] = params[:base_date]
    end

    if session[:base_date] and session[:base_date].to_i > 0
      @base_date_function = "profit_#{session[:base_date]}_month"
      @base_date_string = "추천 후 #{session[:base_date]}달 동안"
    else
      @base_date_function = "profit_recent"
      @base_date_string = "최근 까지"
    end

    @stock_firms.each do |stock_firm|
      stock_firms_row = {}
      stock_firms_row[:stock_firm] = stock_firm
      stock_firms_row[:profit] = stock_firm.send(@base_date_function)

      @stock_firms_rows.push stock_firms_row
    end

    @stock_firms_rows.sort! {|x,y| y[:profit]<=>x[:profit]}

    ranking = 1
    @stock_firms_rows.each do |stock_firms_row|
      stock_firms_row[:ranking] = ranking
      ranking += 1
    end

  end

  def show
    @stock_firm = StockFirm.find(params[:id])
    @recommendations = @stock_firm.recommendations.order("in_date DESC").paginate(:page => params[:page], :per_page => 30)

    if session[:base_date] and session[:base_date].to_i > 0
      @base_date_function = "profit_#{session[:base_date]}_month"
      @base_date_string = "추천 후 #{session[:base_date]}달 동안"
    else
      @base_date_function = "profit_recent"
      @base_date_string = "최근 까지"
    end


  end
end
