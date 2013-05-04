#coding:utf-8
class StockFirmsController < ApplicationController
  def index
    @stock_firms = StockFirm.all
    @stock_firms_rows = []

    unless session[:recent_period_id]
      session[:recent_period_id] = RecentPeriod.last.id
    end

    unless session[:keep_period_id]
      session[:keep_period_id] = KeepPeriod.last.id
    end

    if params[:recent_period_id]
      session[:recent_period_id] = params[:recent_period_id].to_i
    end

    if params[:keep_period_id]
      session[:keep_period_id] = params[:keep_period_id].to_i
    end

    @recent_period = RecentPeriod.find(session[:recent_period_id])
    @keep_period = KeepPeriod.find(session[:keep_period_id])

    @base_date_string = "최근 #{@recent_period.name} 추천을 #{@keep_period.name} 동안 유지할 때"

    @stock_firms.each do |stock_firm|
      stock_firms_row = {}
      stock_firms_row[:stock_firm] = stock_firm
      stock_firms_row[:profit] = stock_firm.analyses.where(:recent_period_id => @recent_period.id, :keep_period_id => @keep_period.id).first.earning_average
      if stock_firms_row[:profit]
        stock_firms_row[:profit] = stock_firms_row[:profit].round(2)
      end

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

    unless session[:recent_period_id]
      session[:recent_period_id] = RecentPeriod.last.id
    end

    unless session[:keep_period_id]
      session[:keep_period_id] = KeepPeriod.last.id
    end

    if params[:recent_period_id]
      session[:recent_period_id] = params[:recent_period_id].to_i
    end

    if params[:keep_period_id]
      session[:keep_period_id] = params[:keep_period_id].to_i
    end

    @recent_period = RecentPeriod.find(session[:recent_period_id])
    @keep_period = KeepPeriod.find(session[:keep_period_id])

    @base_date_string = "최근 #{@recent_period.name} 추천을 #{@keep_period.name} 동안 유지할 때"
  end
end
