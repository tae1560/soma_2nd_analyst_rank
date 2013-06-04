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
    @loss_cut_string = @loss_cut.percent


    @stock_firms.each do |stock_firm|

      stock_firms_row = outcome_of_stock_firm stock_firm
      unless stock_firms_row
        next
      end

      # 소수점 처리 및 소팅을 위한 값 설정
      stock_firms_row[:yearly_profit] = round_or_setting_lowest stock_firms_row[:yearly_profit]
      stock_firms_row[:profit] = round_or_setting_lowest stock_firms_row[:profit]
      stock_firms_row[:variance] = round_or_setting_lowest stock_firms_row[:variance]
      stock_firms_row[:standard_deviation] = round_or_setting_lowest stock_firms_row[:standard_deviation]
      stock_firms_row[:sharpe_ratio] = round_or_setting_lowest stock_firms_row[:sharpe_ratio]


      @stock_firms_rows.push stock_firms_row
    end

    @stock_firms_rows.sort! {|x,y| y[:profit]<=>x[:profit]}

    ranking = 1
    @stock_firms_rows.each do |stock_firms_row|
      stock_firms_row[:ranking] = ranking

      if stock_firms_row[:yearly_profit] == -9999
        stock_firms_row[:yearly_profit] = "-"
      end

      if stock_firms_row[:variance] == -9999
        stock_firms_row[:variance] = "-"
      end

      if stock_firms_row[:profit] == -9999
        stock_firms_row[:profit] = "-"
      end

      if stock_firms_row[:standard_deviation] == -9999
        stock_firms_row[:standard_deviation] = "-"
      end

      if stock_firms_row[:sharpe_ratio] == -9999
        stock_firms_row[:sharpe_ratio] = "-"
      end

      # 위험도 측정
      # 기준 : http://blog.naver.com/PostView.nhn?blogId=kimseye3&logNo=130153076168
      unless stock_firms_row[:sharpe_ratio] == "-"
        if stock_firms_row[:sharpe_ratio] > 0.4 and stock_firms_row[:sharpe_ratio] < 1
          stock_firms_row[:risk] = "양호"
        elsif stock_firms_row[:sharpe_ratio] >= 1
          stock_firms_row[:risk] = "매우 양호"
        else
          stock_firms_row[:risk] = "위험"
        end
      end

      ranking += 1
    end

    #최근 종목

    @recommendations = Recommendation.order("in_date DESC").limit(10)

    save_session_by_regId params["regId"]
    record_push_metric params["notification_id"]

  end
end
