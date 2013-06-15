# coding : UTF-8
class Api::V1::SignalsController < Api::ApiController
  before_filter :find_user_by_auth_token
  def index
  #   TODO : render signal
  #  render :json => @user.stock_firms.to_json(:only => [:name], :methods => [:test_value])
    render :json => [{:signal_id => "1",
                     :stock_firm_name => "삼성증권",
                     :symbol => "035420",
                     :in_date => Time.now.to_s,
                     :keep_period => "30",
                     :asset => "300000"},
                     {:signal_id => "2",
                      :stock_firm_name => "동부증권",
                      :symbol => "005930",
                      :in_date => Time.now.to_s,
                      :keep_period => "15",
                      :asset => "150000""}]

  # signal id, name, 거래일수, 금액
  end
end
