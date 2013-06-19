# coding : UTF-8
class Api::V1::SignalsController < Api::ApiController
  before_filter :find_user_by_auth_token
  def index
  #   TODO : render signal
  #  render :json => @user.stock_firms.to_json(:only => [:name], :methods => [:test_value])

    #render :json => @user.investments.to_json(:only => [:id, :invest_asset], :methods => [:stock_firm_name, :keep_period_days, :recommendations])

    #self.stock_firm.recommendations.(:only => [:in_date, :symbol])

    builder = Jbuilder.new do |json|
      @json_array = []

      @user.investments.find_each do |investment|
        investment.stock_firm.recommendations.where("in_date > '#{investment.start_date - 60.days}'").find_each do |recommendation|
          @json_array.push [recommendation, investment]
        end
      end

      @json_array.sort! { |x,y| y[0].in_date <=> x[0].in_date }

      json.array! @json_array do |array|
        recommendation, investment = array

        json.signal_id investment.id
        json.stock_firm_name investment.stock_firm.name
        json.asset investment.invest_asset.to_s
        json.keep_period investment.keep_period.days.to_s

        json.recommendation_id recommendation.id
        json.symbol recommendation.symbol
        json.stock_name recommendation.stock_code.name
        json.in_date recommendation.in_date
      end

    end

    render :json => builder.target!

  # TODO :  추천일 최근 종가
  # signal id, name, 거래일수, 금액
  end
end
