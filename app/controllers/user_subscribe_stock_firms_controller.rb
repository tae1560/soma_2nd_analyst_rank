class UserSubscribeStockFirmsController < ApplicationController
  def create
    if params["user_id"] and params["stock_firm_id"]
      begin
        user = User.find(params["user_id"])
        stock_firm = StockFirm.find(params["user_id"])

        if user and stock_firm
          user.subscribe stock_firm
        end

        render :json => {"result" => "success"}
      rescue
        puts "rescue"
        bt = $!.backtrace * "\n  "
        ($stderr << "error: #{$!.inspect}\n  #{bt}\n").flush

        render :json => {"result" => "failed", "message" => "invalid id"}
      end
    else
      render :json => {"result" => "failed", "message" => "needed user_id and stock_firm_id params"}
    end
  end

  def destroy
    begin
      @user_subscribe_stock_firm = UserSubscribeStockFirm.find(params[:id])
      @user_subscribe_stock_firm.destroy

      redirect_to :back
    rescue
      render :json => {"result" => "failed", "message" => "Cannot find UserSubscribeStockFirm(#{params[:id]})"}
    end
  end
end
