# coding: utf-8
require 'tasks/day_candle_crawler'
require 'tasks/code_crawler'
require 'tasks/recommendation_crawler'

namespace :manager do
  task :cron => :environment do
    puts "start manager:cron"
    Rake::Task["crawler:stock_codes"].invoke
    Rake::Task["crawler:day_candles"].invoke
    Rake::Task["crawler:recommendations"].invoke
    Rake::Task["calculator:profit"].invoke
    Utility.send_message_to_all "증권사 추천왕", "새로운 추천정보가 업데이트 되었습니다."
  end
end