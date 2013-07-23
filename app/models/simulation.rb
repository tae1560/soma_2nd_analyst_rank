# coding: utf-8
class Simulation < ActiveRecord::Base
  attr_accessible :total_asset, :invest_asset, :last_modified, :balance_asset, :virtual_asset
  belongs_to :stock_firm
  belongs_to :recent_period
  belongs_to :keep_period
  belongs_to :loss_cut
  has_many :virtual_assets

  def self.find_or_create_by_filter stock_firm, recent_period, keep_period, loss_cut, total_asset, invest_asset
    simulation = Simulation.where(:stock_firm_id => stock_firm.id,
                    :recent_period_id => recent_period.id,
                    :keep_period_id => keep_period.id,
                    :loss_cut_id => loss_cut.id,
                    :total_asset => total_asset,
                    :invest_asset => invest_asset).first

    unless simulation
      simulation = Simulation.new(:total_asset => total_asset,
                                   :invest_asset => invest_asset)
      simulation.stock_firm = stock_firm
      simulation.recent_period = recent_period
      simulation.keep_period = keep_period
      simulation.loss_cut = loss_cut
      simulation.save!
    end
    return simulation
  end

  def is_need_to_update?
    !self.last_modified or Time.now - self.last_modified > 1.days
  end

  def self.create_recommendation_print recommendation, keep_period
    recommendation_print = {}
    recommendation_print[:recommendation] = recommendation
    in_day_candle = recommendation_print[:in_day_candle] = recommendation.get_in_day_candle
    out_day_candle = recommendation_print[:out_day_candle] = recommendation.get_out_day_candle keep_period.days.days

    recommendation_print[:stock_code] = recommendation.stock_code
    recommendation_print[:stock_code_name] = recommendation.stock_code.name.gsub("보통주","")
    recommendation_print[:recommendation_in_date] = Utility.utc_datetime_to_kor_str recommendation.in_date

    recommendation_print[:state] = "구매대기"
    recommendation_print[:volumn] = 0

    recommendation_print[:symbol] = recommendation.symbol
    recommendation_print[:stock_firm_name] = recommendation.stock_firm.name
    recommendation_print[:in_date] = Utility.utc_datetime_to_kor_str recommendation.in_date
    recommendation_print[:in_day_candle_date] = in_day_candle && Utility.utc_datetime_to_kor_str(in_day_candle.trading_date)
    recommendation_print[:in_day_candle_open] = in_day_candle && in_day_candle.open || "-"
    recommendation_print[:out_day_candle_date] = out_day_candle && Utility.utc_datetime_to_kor_str(out_day_candle.trading_date)
    recommendation_print[:out_day_candle_close] = out_day_candle && out_day_candle.close || "-"
    recommendation_print[:profit] = "-"
    return recommendation_print
  end
end
