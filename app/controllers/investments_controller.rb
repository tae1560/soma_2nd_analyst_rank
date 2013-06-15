class InvestmentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @investments = current_user.investments.all

  end

  def show
    @investment = current_user.investments.find_by_id(params[:id])
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
