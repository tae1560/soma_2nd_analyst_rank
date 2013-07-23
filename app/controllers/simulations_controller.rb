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

    if LossCut.where(:percent => -1).last
      @loss_cut = LossCut.where(:percent => -1).last
      #@loss_cut = LossCut.find_by_id(session[:loss_cut_id])
    end

    # setting params
    unless params[:stock_firm_id] and StockFirm.find_by_id(params[:stock_firm_id])
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
    @stock_firm_outcome = @stock_firm.outcome_of_stock_firm  @recent_period, @keep_period, @loss_cut

    # getting require information
    @start_date = Time.now - @recent_period.days.days
    @recommendations = @stock_firm.recommendations.where("in_date > '#{@start_date}'").order("in_date DESC")

    # calculate
    @recommendation_prints = []
    @orders = []
    @recommendations.each do |recommendation|
      recommendation_print = Simulation.create_recommendation_print recommendation, @keep_period
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
    @asset_history = {}
    @asset_history[Utility.utc_datetime_to_kor_str @start_date] = [0, [], @total_asset, 0]
    @current_stock_codes = []

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

          # 가상 자산 history 저장
          in_day_candle = recommendation_print[:in_day_candle]
          if in_day_candle
            unless @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date]
              @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date] = [0,[],0,0]
            end
            @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][0] -= recommendation_print[:in_price]
            @current_stock_codes.push recommendation_print
            @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][1] = @current_stock_codes.clone
            @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][2] = @rest_asset
          end
        end
      else
        if recommendation_print[:out_day_candle_close]
          recommendation_print[:out_price] = recommendation_print[:volumn] * recommendation_print[:out_day_candle_close] * (1-out_tax)

          recommendation_print[:out_price] = recommendation_print[:out_price].round
          @rest_asset += recommendation_print[:out_price]
          recommendation_print[:profit] = (recommendation_print[:out_price] - recommendation_print[:in_price])
          if recommendation_print[:volumn] > 0
            recommendation_print[:state] = "매도완료"
          end
          recommendation_print[:profit_ratio] = ((recommendation_print[:out_price] - recommendation_print[:in_price]) / recommendation_print[:in_price].to_f) * 100
          recommendation_print[:profit_ratio] = recommendation_print[:profit_ratio].round(2)

          # 가상 자산 history 저장
          out_day_candle = recommendation_print[:out_day_candle]
          if out_day_candle
            unless @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date]
              @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date] = [0,[],0,0]
            end
            @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][0] += recommendation_print[:out_price]
            @current_stock_codes.delete recommendation_print
            @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][1] = @current_stock_codes.clone
            @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][2] = @rest_asset
          end
        end
      end
    end

    # caching : 시뮬레이션 필요가 있을경우만 하기
    simulation = Simulation.find_or_create_by_filter(@stock_firm, @recent_period, @keep_period, @loss_cut, @total_asset, @invest_asset)
    if simulation.is_need_to_update?
      virtual_asset = 0
      @recommendation_prints.each do |recommendation_print|
        # 최종 가상자산 계산
        if recommendation_print[:state] == "보유중"
          out_day_candle = recommendation_print[:stock_code].day_candles.order(:trading_date).last
          virtual_asset += recommendation_print[:volumn] * out_day_candle.open * (1-out_tax)
        end
      end
      virtual_asset = virtual_asset.round
      simulation.virtual_asset = virtual_asset
      simulation.balance_asset = @rest_asset
      simulation.last_modified = Time.now
      simulation.save!
    end

    # 가상자산 계산
    if params["asset"] == 1 or params["asset"] == "1"
      @asset_history.each do |k,v|
        virtual_asset = VirtualAsset.find_or_create(simulation, k.to_datetime)
        if virtual_asset.is_need_to_update?
          virtual_asset_sum = 0
          v[1].collect{|e| virtual_asset_sum += e[:volumn] * (1-out_tax) * e[:stock_code].day_candles.where("trading_date >= '#{Utility.kor_str_to_utc_datetime k}'").order(:trading_date).first.open}
          virtual_asset.last_modified = Time.now
          virtual_asset.amount = virtual_asset_sum
          virtual_asset.save!
        end

        v[3] = virtual_asset.amount
      end

      @recommendation_prints.each do |recommendation_print|
        # 가상자산 입력
        if recommendation_print[:in_day_candle]
          asset_history = @asset_history[Utility.utc_datetime_to_kor_str recommendation_print[:in_day_candle].trading_date]
          recommendation_print[:in_profit_asset] = asset_history[2] + asset_history[3]
        end

        if recommendation_print[:out_day_candle]
          asset_history = @asset_history[Utility.utc_datetime_to_kor_str recommendation_print[:out_day_candle].trading_date]
          recommendation_print[:out_profit_asset] = asset_history[2] + asset_history[3]
        end
      end
    end


    @current_virtual_asset = simulation.virtual_asset
    @profit_asset = simulation.balance_asset + simulation.virtual_asset

    # 최종 자산 그래프 추가
    @asset_history[Utility.utc_datetime_to_kor_str Time.now] = [0, @current_stock_codes.clone, simulation.balance_asset, simulation.virtual_asset]
  end
end
