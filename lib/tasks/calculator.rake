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
end