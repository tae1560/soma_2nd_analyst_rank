class StockFirm < ActiveRecord::Base
  attr_accessible :name, :mongo_id

  has_many :recommendations
  has_many :analyses

  has_many :users, :through => :user_subscribe_stock_firms

  def self.find_or_create_instance id, name
    stock_firm = StockFirm.find_by_id(id)
    unless stock_firm
      stock_firm = StockFirm.new(:name => name)
      stock_firm.id = id
      unless stock_firm.save
        "ERROR : stock_firm did not saved : #{stock_firm.inspect}"
      end
    end
    return stock_firm
  end

  def calculate_profit
    #profiler = MethodProfiler.observe(Analysis)
    #profiler2 = MethodProfiler.observe(Recommendation)

    KeepPeriod.find_each do |keep_period|

      RecentPeriod.find_each do |recent_period|
        #puts profiler.report
        #puts profiler2.report


        LossCut.find_each do |loss_cut|
          analysis = self.analyses.where(:keep_period_id => keep_period.id, :recent_period_id => recent_period.id, :loss_cut_id => loss_cut.id).first
          unless analysis
            analysis = Analysis.create
            analysis.keep_period = keep_period
            analysis.recent_period = recent_period
            analysis.loss_cut = loss_cut
            self.analyses << analysis
          end

          puts "stock_firm : #{analysis.stock_firm.name} keep : #{analysis.keep_period.name}, recent : #{analysis.recent_period.name}, loss_cut : #{loss_cut.percent}"

          # start calculate
          profit_array = []

          # recent_period
          filtered_recommendations = nil
          if analysis.recent_period.days < 0
            filtered_recommendations = self.recommendations
          else
            filtered_recommendations = self.recommendations.where("in_date > '#{Time.now - analysis.recent_period.days.days}'")
          end

          filtered_recommendations.find_each do |recommendation|
            profit = recommendation.get_profit analysis.keep_period.days.days, loss_cut.percent

            if profit
              profit_array.push profit
            end
          end

          # calculate average and variance
          sum_of_profit = 0
          count_winner = 0
          count_loser = 0
          profit_array.each do |profit|
            sum_of_profit += profit

            # added winning rate of stock_firm
            if profit > 0
              count_winner += 1
            else
              count_loser += 1
            end
          end

          earning_average = nil
          if profit_array.size > 0
            earning_average = sum_of_profit / profit_array.size
          end

          analysis.count_winner = count_winner
          analysis.count_loser = count_loser

          if earning_average
            sum_of_profit_for_variance = 0
            profit_array.each do |profit|
              sum_of_profit_for_variance += ((profit - earning_average) * (profit - earning_average))
            end

            analysis.earning_average = earning_average
            analysis.earning_variance = sum_of_profit_for_variance / profit_array.size
            analysis.save
          else
            analysis.earning_average = nil
            analysis.earning_variance = nil
            analysis.save
          end
        end
      end
    end

    self.save
  end

  # 증권사와 현재 필터링에 대한 분석정보
  def outcome_of_stock_firm recent_period, keep_period, loss_cut
    analysis = self.analyses.where(:recent_period_id => recent_period.id, :keep_period_id => keep_period.id, :loss_cut_id => loss_cut.id).first
    unless analysis
      return nil
    end
    stock_firms_row = {}
    stock_firms_row[:id] = self.id
    stock_firms_row[:stock_firm] = self
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
      stock_firms_row[:sharpe_ratio] = (stock_firms_row[:profit] - (1.1 / (365 / keep_period.days))) / stock_firms_row[:standard_deviation]
    end

    # 연환산 수익률
    if stock_firms_row[:profit]
      stock_firms_row[:yearly_profit] = stock_firms_row[:profit]

      # 연 환산 (복리)
      if analysis.earning_average
        number_of_fund = 365 / keep_period.days
        stock_firms_row[:yearly_profit] = (1 + (stock_firms_row[:yearly_profit] / 100)) ** (number_of_fund)
        stock_firms_row[:yearly_profit] = (stock_firms_row[:yearly_profit] - 1) * 100
      end
    end

    # 추천 수
    if recent_period and recent_period.days > 0
      stock_firms_row[:number_of_recommendations] = self.recommendations.where("in_date > '#{Time.now - recent_period.days.days}'").count

    else
      stock_firms_row[:number_of_recommendations] = self.recommendations.count
    end

    return stock_firms_row
  end
end
