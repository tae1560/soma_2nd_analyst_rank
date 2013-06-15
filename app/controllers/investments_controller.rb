# coding: UTF-8
class InvestmentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @investments = current_user.investments.all

  end

  def show
    @investment = current_user.investments.find_by_id(params[:id])
    @recommendations = @investment.stock_firm.recommendations.where("in_date > '#{@investment.start_date - 50.days}'").order("in_date DESC")

    @keep_period = @investment.keep_period
    @recent_period = @investment.recent_period
    @loss_cut = @investment.loss_cut

    @rest_asset = @investment.total_asset

    @profit_asset = 0

    @recommendation_prints = []
    @recommendations.each do |recommendation|
      recommendation_print = {}
      in_day_candle = recommendation.get_in_day_candle
      out_day_candle = recommendation.get_out_day_candle @keep_period.days.days
      #profit = recommendation.get_profit @keep_period.days.days


      recommendation_print[:stock_code_name] = recommendation.stock_code.name.gsub("보통주","")
      recommendation_print[:state] = if out_day_candle then "매도완료" else if in_day_candle then "보유중" else "구매대기" end end

      real_invest_asset = [@investment.invest_asset, @rest_asset].min
      recommendation_print[:volumn] = if in_day_candle then real_invest_asset / in_day_candle.open else 0 end

      @rest_asset -= in_day_candle.open * recommendation_print[:volumn]

      if out_day_candle then @rest_asset += out_day_candle.close * recommendation_print[:volumn] end

      recommendation_print[:symbol] = recommendation.symbol
      recommendation_print[:stock_firm_name] = recommendation.stock_firm.name
      recommendation_print[:in_date] = Utility.utc_datetime_to_kor_str recommendation.in_date
      recommendation_print[:in_day_candle_date] = in_day_candle && Utility.utc_datetime_to_kor_str(in_day_candle.trading_date) || "-"
      recommendation_print[:in_day_candle_open] = in_day_candle && in_day_candle.open || "-"
      recommendation_print[:out_day_candle_date] = out_day_candle && Utility.utc_datetime_to_kor_str(out_day_candle.trading_date) || "-"
      recommendation_print[:out_day_candle_close] = out_day_candle && out_day_candle.close || "-"
      recommendation_print[:profit] = if in_day_candle and out_day_candle then (out_day_candle.close - in_day_candle.open) * recommendation_print[:volumn] else "-" end
      unless recommendation_print[:profit] == "-" then @profit_asset += recommendation_print[:profit] end
      @recommendation_prints.push recommendation_print
    end


  end

  def new
    analysis_filtering_with_parameters params

    @investment = Investment.new
    @stock_firm = StockFirm.find_by_id(params[:stock_firm_id])
    #render :json => params
  end

  def create
    @investment = Investment.new
    @investment.total_asset = params[:investment][:total_asset]
    @investment.invest_asset = params[:investment][:invest_asset]
    @investment.user = User.find_by_id(params[:investment][:user_id])
    @investment.stock_firm = StockFirm.find_by_id(params[:investment][:stock_firm_id])
    @investment.keep_period = KeepPeriod.find_by_id(params[:investment][:keep_period_id])
    @investment.recent_period = RecentPeriod.find_by_id(params[:investment][:recent_period_id])
    @investment.loss_cut = LossCut.find_by_id(params[:investment][:loss_cut_id])
    @investment.start_date = Time.now

    respond_to do |format|
      if @investment.save
        format.html { redirect_to @investment, notice: 'Investment was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end


    #user, stock_firm, keep_period, recent_period, loss_cut,  start_date, total_asset, invest_asset
    #user = User.find_by_id(params[:user_id])
    #stock_firm = User.find_by_id(params[:stock_firm_id])
    #keep_period = User.find_by_id(params[:keep_period_id])
    #recent_period = User.find_by_id(params[:recent_period_id])
    #recent_period = User.find_by_id(params[:recent_period_id])

  end
end
