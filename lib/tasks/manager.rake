# coding: utf-8
require 'tasks/day_candle_crawler'
require 'tasks/code_crawler'
require 'tasks/recommendation_crawler'

namespace :manager do
  task :cron => :environment do
    puts "start manager:cron"
    Rake::Task["crawler:day_candles"].invoke
    Rake::Task["crawler:recommendations"].invoke
    Rake::Task["calculator:profit"].invoke
  end
end