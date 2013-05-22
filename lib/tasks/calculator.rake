# coding: utf-8
require 'tasks/day_candle_crawler'
require 'tasks/code_crawler'
require 'tasks/recommendation_crawler'

namespace :calculator do
  task :profit => :environment do
    puts "start calculator:profit"
    StockFirm.find_each do |stock_firm|
      stock_firm.calculate_profit
    end
  end

  task :mdd => :environment do
    start_time = Time.now
    puts "start calculator:mdd on #{start_time}"
    StockFirm.find_each do |stock_firm|

      #TOOD : 우선 걸리는 시간 테스트

      mdds = []
      KeepPeriod.find_each do |keep_period|
        RecentPeriod.find_each do |recent_period|
          puts "stock_firm : #{stock_firm.name} keep : #{keep_period.name}, recent : #{recent_period.name}"

          # recent_period
          filtered_recommendations = nil
          if recent_period.days < 0
            filtered_recommendations = stock_firm.recommendations
          else
            filtered_recommendations = stock_firm.recommendations.where("in_date > '#{Time.now - recent_period.days.days}'")
          end

          filtered_recommendations.find_each do |recommendation|
            mdd = recommendation.get_mdd keep_period.days.days

            if mdd
              mdds.push mdd
            end
          end
        end
      end




    end
    end_time = Time.now
    puts "ended calculator:mdd on #{end_time}"

    puts "elapsed time of calculator:mdd : #{end_time - start_time}"
  end
end