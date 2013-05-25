#coding:utf-8

class HomeController < ApplicationController
  def index
    analysis_filtering_with_parameters params

    # 순위
    @stock_firms = StockFirm.all
    @stock_firms_rows = []

    @base_date_string = "최근 #{@recent_period.name} 추천을 #{@keep_period.name} 동안 유지할 때"
    @recent_period_string = @recent_period.name
    @keep_period_string = @keep_period.name


    @stock_firms.each do |stock_firm|
      stock_firms_row = {}
      stock_firms_row[:id] = stock_firm.id
      stock_firms_row[:stock_firm] = stock_firm
      stock_firms_row[:profit] = stock_firm.analyses.where(:recent_period_id => @recent_period.id, :keep_period_id => @keep_period.id).first.earning_average
      if stock_firms_row[:profit]
        stock_firms_row[:profit] = stock_firms_row[:profit].round(2)
      else
        stock_firms_row[:profit] = -9999
      end

      stock_firms_row[:variance] = stock_firm.analyses.where(:recent_period_id => @recent_period.id, :keep_period_id => @keep_period.id).first.earning_variance
      if stock_firms_row[:variance]
        stock_firms_row[:variance] = Math.sqrt(stock_firms_row[:variance]).round(2)
      else
        stock_firms_row[:variance] = -9999
      end

      @stock_firms_rows.push stock_firms_row
    end

    @stock_firms_rows.sort! {|x,y| y[:profit]<=>x[:profit]}

    ranking = 1
    @stock_firms_rows.each do |stock_firms_row|
      stock_firms_row[:ranking] = ranking

      if stock_firms_row[:profit] == -9999
        stock_firms_row[:profit] = "-"
      end

      if stock_firms_row[:variance] == -9999
        stock_firms_row[:variance] = "-"
      end

      ranking += 1
    end

    #최근 종목

    @recommendations = Recommendation.order("in_date DESC").limit(10)

    save_session_by_regId params["regId"]
    record_push_metric params["notification_id"]

  end
end
