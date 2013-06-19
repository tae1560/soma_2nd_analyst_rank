#coding:utf-8
class StockFirmsController < ApplicationController
  def index
    analysis_filtering_with_parameters params
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
        if stock_firms_row[:sharpe_ratio] >= 0.3 and stock_firms_row[:sharpe_ratio] < 1
          stock_firms_row[:risk] = "양호"
          stock_firms_row[:risk_style] = "perfect"
        elsif stock_firms_row[:sharpe_ratio] >= 1
          stock_firms_row[:risk] = "매우 양호"
          stock_firms_row[:risk_style] = "perfect"
        elsif stock_firms_row[:sharpe_ratio] >= 0.2 and stock_firms_row[:sharpe_ratio] < 0.3
          stock_firms_row[:risk] = "보통"
          stock_firms_row[:risk_style] = "good"
        else
          stock_firms_row[:risk] = "위험"
          stock_firms_row[:risk_style] = "bad"
        end
      else
        stock_firms_row[:risk] = "-"
        stock_firms_row[:risk_style] = ""

      end

      ranking += 1
    end

    # push metric
    save_session_by_regId params["regId"]
    record_push_metric params["notification_id"]

  end

  def show
    analysis_filtering_with_parameters params

    @stock_firm = StockFirm.find(params[:id])

    if @recent_period and @recent_period.days > 0
      @recommendations = @stock_firm.recommendations.where("in_date > '#{Time.now - @recent_period.days.days}'").order("in_date DESC").paginate(:page => params[:page], :per_page => 50)
    else
      @recommendations = @stock_firm.recommendations.order("in_date DESC").paginate(:page => params[:page], :per_page => 50)
    end


    @base_date_string = "최근 #{@recent_period.name} 추천을 #{@keep_period.name} 동안 유지할 때"
    @recent_period_string = @recent_period.name
    @keep_period_string = @keep_period.name
    @loss_cut_string = @loss_cut.percent



    # added stock_firm outcome
    @stock_firm_outcome = outcome_of_stock_firm @stock_firm
  end

  # 증권사와 현재 필터링에 대한 분석정보
  def outcome_of_stock_firm stock_firm
    analysis = stock_firm.analyses.where(:recent_period_id => @recent_period.id, :keep_period_id => @keep_period.id, :loss_cut_id => @loss_cut.id).first
    unless analysis
      return nil
    end
    stock_firms_row = {}
    stock_firms_row[:id] = stock_firm.id
    stock_firms_row[:stock_firm] = stock_firm
    stock_firms_row[:analysis] = analysis
    stock_firms_row[:profit] = analysis.earning_average
    stock_firms_row[:variance] = analysis.earning_variance

    # 표준편차
    if stock_firms_row[:variance]
      stock_firms_row[:standard_deviation] = Math.sqrt(stock_firms_row[:variance])
    end

    # 샤프지수 : Sharpe ratio
    # 샤프지수 = (펀드수익률 - 무위험수익률) / 위험 (표준편차)
    if stock_firms_row[:profit] and stock_firms_row[:standard_deviation] and stock_firms_row[:standard_deviation] != 0
      stock_firms_row[:sharpe_ratio] = (stock_firms_row[:profit] - (1.1 / (365 / @keep_period.days))) / stock_firms_row[:standard_deviation]
    end

    # 연환산 수익률
    if stock_firms_row[:profit]
      stock_firms_row[:yearly_profit] = stock_firms_row[:profit]

      # 연 환산 (복리)
      if analysis.earning_average
        number_of_fund = 365 / @keep_period.days
        stock_firms_row[:yearly_profit] = (1 + (stock_firms_row[:yearly_profit] / 100)) ** (number_of_fund)
        stock_firms_row[:yearly_profit] = (stock_firms_row[:yearly_profit] - 1) * 100
      end
    end

    # 추천 수
    if @recent_period and @recent_period.days > 0
      stock_firms_row[:number_of_recommendations] = stock_firm.recommendations.where("in_date > '#{Time.now - @recent_period.days.days}'").count

    else
      stock_firms_row[:number_of_recommendations] = stock_firm.recommendations.count
    end

    return stock_firms_row
  end

  def round_or_setting_lowest value
    # 소수점 처리 및 소팅을 위한 값 설정
    if value
      return value.round(2)
    else
      return -9999
    end
  end
end
