#coding : utf-8
class SimulationsController < ApplicationController
  def search
    #  받는 parameter
    #  - 증권사
    #  - 전체자산
    #  - 각 투자액
    #  - 시작날짜 (session)
    #  - 보유기간 (session)

    # setting values
    # 세금 + 증권사 수수료
    in_tax = (0.015) / 100
    out_tax = (0.3 + 0.015) / 100

    if params["simulations"]
      params[:stock_firm_id] = params["simulations"]["stock_firm"]
      params[:recent_period_id] = params["simulations"]["recent_period"]
      params[:keep_period_id] = params["simulations"]["keep_period"]
    end

    # session params
    analysis_filtering_with_parameters params

    # setting params
    unless params[:simulations][:stock_firm_id] and StockFirm.find_by_id(params[:stock_firm_id])
      params[:stock_firm_id] = StockFirm.first
    end

    unless params[:total_asset]
      params[:total_asset] = 15000000
    end

    unless params[:invest_asset]
      params[:invest_asset] = params[:total_asset] / 10
    end

    # getting params
    @stock_firm = StockFirm.find_by_id(params[:stock_firm_id])
    @total_asset = params[:total_asset].to_i
    @invest_asset = params[:invest_asset].to_i

    # getting require information
    @start_date = Time.now - @recent_period.days.days
    @recommendations = @stock_firm.recommendations.where("in_date > '#{@start_date}'").order("in_date DESC")


    # calculate
    @recommendation_prints = []
    @orders = []
    @recommendations.each do |recommendation|
      recommendation_print = {}
      recommendation_print[:recommendation] = recommendation
      in_day_candle = recommendation_print[:in_day_candle] = recommendation.get_in_day_candle
      out_day_candle = recommendation_print[:out_day_candle] = recommendation.get_out_day_candle @keep_period.days.days
      #profit = recommendation.get_profit @keep_period.days.days


      recommendation_print[:stock_code] = recommendation.stock_code
      recommendation_print[:stock_code_name] = recommendation.stock_code.name.gsub("보통주","")
      recommendation_print[:recommendation_in_date] = Utility.utc_datetime_to_kor_str recommendation.in_date

      #recommendation_print[:state] = if out_day_candle then "매도완료" else if in_day_candle then "보유중" else "구매대기" end end
      recommendation_print[:state] = "구매대기"
      recommendation_print[:volumn] = 0
      #
      #real_invest_asset = [@investment.invest_asset, @rest_asset].min
      #recommendation_print[:volumn] = if in_day_candle then real_invest_asset / in_day_candle.open else 0 end
      #
      #if in_day_candle
      #  @rest_asset -= in_day_candle.open * recommendation_print[:volumn]
      #end
      #
      #if out_day_candle then @rest_asset += out_day_candle.close * recommendation_print[:volumn] end
      #
      #recommendation_print[:symbol] = recommendation.symbol
      #recommendation_print[:stock_firm_name] = recommendation.stock_firm.name
      #recommendation_print[:in_date] = Utility.utc_datetime_to_kor_str recommendation.in_date
      #recommendation_print[:in_day_candle_date] = in_day_candle && Utility.utc_datetime_to_kor_str(in_day_candle.trading_date) || "-"
      recommendation_print[:in_day_candle_open] = in_day_candle && in_day_candle.open || "-"
      #recommendation_print[:out_day_candle_date] = out_day_candle && Utility.utc_datetime_to_kor_str(out_day_candle.trading_date) || "-"
      recommendation_print[:out_day_candle_close] = out_day_candle && out_day_candle.close || "-"
      recommendation_print[:profit] = "-"
      #recommendation_print[:profit] = if in_day_candle and out_day_candle then (out_day_candle.close - in_day_candle.open) * recommendation_print[:volumn] else "-" end
      #unless recommendation_print[:profit] == "-" then @profit_asset += recommendation_print[:profit] end
      @recommendation_prints.push recommendation_print

    #  adding order
      if recommendation_print[:in_day_candle]
        order = {}
        order[:date] = recommendation_print[:in_day_candle].trading_date
        order[:type] = :in
        order[:recommendation_print] = recommendation_print
        @orders.push order
      end

      if recommendation_print[:out_day_candle]
        order = {}
        order[:date] = recommendation_print[:out_day_candle].trading_date
        order[:type] = :out
        order[:recommendation_print] = recommendation_print
        @orders.push order
      end
    end

    @rest_asset = @total_asset
    @profit_asset = 0

    @orders.sort! {|x,y| x[:date] <=> y[:date]}
    @orders.each do |order|
      recommendation_print = order[:recommendation_print]
      if order[:type] == :in
        recommendation_print[:rest_asset] = @rest_asset
        if recommendation_print[:in_day_candle_open]
          real_invest_asset = [@invest_asset, @rest_asset].min
          recommendation_print[:volumn] = (real_invest_asset / recommendation_print[:in_day_candle_open] / (1+in_tax)).to_i
          recommendation_print[:in_price] = recommendation_print[:volumn] * recommendation_print[:in_day_candle_open] * (1+in_tax)
          if recommendation_print[:volumn] == 0
            recommendation_print[:state] = "잔액부족"
          else
            recommendation_print[:state] = "보유중"
          end

          recommendation_print[:in_price] = recommendation_print[:in_price].round
          @rest_asset -= recommendation_print[:in_price]
        end
        #recommendation_print[:rest_asset] = @rest_asset
      else
        if recommendation_print[:out_day_candle_close]
          recommendation_print[:out_price] = recommendation_print[:volumn] * recommendation_print[:out_day_candle_close] * (1-out_tax)

          recommendation_print[:out_price] = recommendation_print[:out_price].round
          @rest_asset += recommendation_print[:out_price]
          recommendation_print[:profit] = (recommendation_print[:out_price] - recommendation_print[:in_price])
          if recommendation_print[:volumn] > 0
            recommendation_print[:state] = "매도완료"
          end
        end
      end
    end

    @current_abstract_asset = 0
    @recommendation_prints.each do |recommendation_print|

      if recommendation_print[:state] == "보유중"
        #recommendation_print[:out_day_candle_close]
        out_day_candle = recommendation_print[:stock_code].day_candles.order(:trading_date).last
        @current_abstract_asset += recommendation_print[:volumn] * out_day_candle.close * (1-out_tax)
        @current_abstract_asset = @current_abstract_asset.round
      end
    end

    @profit_asset = @current_abstract_asset + @rest_asset

  end
end
