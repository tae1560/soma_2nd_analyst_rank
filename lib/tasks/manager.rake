# coding: utf-8
require 'tasks/day_candle_crawler'
require 'tasks/code_crawler'
require 'tasks/recommendation_crawler'

namespace :manager do
  task :cron => :environment do
    start_time = Time.now
    puts "start manager:cron on #{start_time}"

    Rake::Task["crawler:stock_codes"].invoke
    Rake::Task["crawler:day_candles"].invoke
    Rake::Task["crawler:recommendations"].invoke
    Rake::Task["calculator:profit"].invoke

    # 실제 추천정보가 변화될때에 푸쉬
    if Recommendation.order("in_date DESC").first.in_date > Time.now - 1.days
      Utility.send_message_to_all "증권사 추천왕", "새로운 추천정보가 업데이트 되었습니다."
    end

    end_time = Time.now
    puts "ended manager:cron on #{end_time}"

    puts "elapsed time of manager:cron : #{end_time - start_time}"

  end

  task :no_message => :environment do
    start_time = Time.now
    puts "start manager:no_message on #{start_time}"

    Rake::Task["crawler:stock_codes"].invoke
    Rake::Task["crawler:day_candles"].invoke
    Rake::Task["crawler:recommendations"].invoke
    Rake::Task["calculator:profit"].invoke

    end_time = Time.now
    puts "ended manager:no_message on #{end_time}"

    puts "elapsed time of manager:no_message : #{end_time - start_time}"
  end
end