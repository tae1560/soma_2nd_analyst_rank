class MongoStockFirm
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "stock_firms"

  field :name, type: String
  
  has_many :analyses, :class_name => "MongoAnalysis", :inverse_of => :stock_firm
  has_many :recommendations, :class_name => "MongoRecommendation", :inverse_of => :stock_firm

  validates_uniqueness_of :name
  validates_presence_of :name

  index({ name: 1}, { unique: true })

  def calculate_profit
    MongoKeepPeriod.each do |keep_period|
      MongoRecentPeriod.each do |recent_period|
        MongoLossCut.each do |loss_cut|
          analysis = self.analyses.where(:keep_period_id => keep_period.id, :recent_period_id => recent_period.id, :loss_cut_id => loss_cut.id).first
          unless analysis
            analysis = MongoAnalysis.create
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
            #filtered_recommendations = self.recommendations.where("in_date > '#{Time.now - analysis.recent_period.days.days}'")
            filtered_recommendations = self.recommendations.where(:in_date.gt => (Time.now - analysis.recent_period.days.days))
          end

          filtered_recommendations.each do |recommendation|
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

end