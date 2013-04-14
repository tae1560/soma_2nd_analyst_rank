# coding: utf-8
require 'tasks/day_candle_crawler'
require 'tasks/code_crawler'
require 'tasks/recommendation_crawler'

namespace :parser do
  task :stock_codes => :environment do
    puts "start parser:stock_codes"
    RawStockCode.find_each do |raw_stock_code|
      raw_stock_code.parse_and_save
    end

  end

  task :day_candles => :environment do
    puts "start parser:day_candles"
    RawDayCandle.find_each do |raw_day_candle|
      raw_day_candle.parse_and_save
    end
  end

  task :recommendations => :environment do
    puts "start parser:recommendations"
    RawRecommendation.find_each do |raw_recommendation|
      raw_recommendation.parse_and_save
    end
  end

  task :all => :environment do
    puts "start parser:all"

    puts "stock_code"
    StockCode.destroy_all
    RawStockCode.find_each do |raw_stock_code|
      raw_stock_code.parse_and_save
    end

    puts "day_candle"
    DayCandle.destroy_all
    RawDayCandle.find_each do |raw_day_candle|
      raw_day_candle.parse_and_save
    end

    puts "recommendations"
    Recommendation.destroy_all
    RawRecommendation.find_each do |raw_recommendation|
      raw_recommendation.parse_and_save
    end
  end
end