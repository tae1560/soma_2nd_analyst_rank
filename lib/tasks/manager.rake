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

#   translate database to mongo
  task :mongify => :environment do
    task_name = "manager:mongify"
    start_time = Time.now
    puts "start #{task_name} on #{start_time}"


    # Recent Period
    sub_task_name = "converting recent_period"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    RecentPeriod.find_each do |recent_period|
    #RecentPeriod.where(:mongo_id => nil).find_each do |recent_period|
      mongo_recent_period = MongoRecentPeriod.where(:days => recent_period.days, :name => recent_period.name).first
      unless mongo_recent_period
        mongo_recent_period = MongoRecentPeriod.new
      end

      mongo_recent_period.name = recent_period.name
      mongo_recent_period.days = recent_period.days
      if mongo_recent_period.save
        recent_period.mongo_id = mongo_recent_period.id.to_s
        recent_period.save
      else
        puts "error on mongo_recent_period.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"




    # Keep Period
    sub_task_name = "converting keep_period"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    KeepPeriod.find_each do |keep_period|
    #KeepPeriod.where(:mongo_id => nil).find_each do |keep_period|
      mongo_keep_period = MongoKeepPeriod.where(:days => keep_period.days, :name => keep_period.name).first
      unless mongo_keep_period
        mongo_keep_period = MongoKeepPeriod.new
      end

      mongo_keep_period.name = keep_period.name
      mongo_keep_period.days = keep_period.days
      if mongo_keep_period.save
        keep_period.mongo_id = mongo_keep_period.id.to_s
        keep_period.save
      else
        puts "error on mongo_keep_period.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"



    # Loss Cut
    sub_task_name = "converting loss_cut"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    LossCut.find_each do |loss_cut|
    #LossCut.where(:mongo_id => nil).find_each do |loss_cut|
      mongo_loss_cut = MongoLossCut.where(:percent => loss_cut.percent).first
      unless mongo_loss_cut
        mongo_loss_cut = MongoLossCut.new
      end

      mongo_loss_cut.percent = loss_cut.percent
      if mongo_loss_cut.save
        loss_cut.mongo_id = mongo_loss_cut.id.to_s
        loss_cut.save
      else
        puts "error on mongo_loss_cut.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"



    # StockCode
    sub_task_name = "converting stock_code"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    #StockCode.find_each do |stock_code|
    StockCode.where(:mongo_id => nil).find_each do |stock_code|
      mongo_stock_code = MongoStockCode.where(:symbol => stock_code.symbol).first
      unless mongo_stock_code
        mongo_stock_code = MongoStockCode.new
      end
      mongo_stock_code.name = stock_code.name
      mongo_stock_code.eng_name = stock_code.eng_name
      mongo_stock_code.symbol = stock_code.symbol
      if mongo_stock_code.save
        stock_code.mongo_id = mongo_stock_code.id.to_s
        stock_code.save
      else
        puts "error on mongo_stock_code.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"





    # DayCandle
    sub_task_name = "converting day_candle"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    DayCandle.where(:mongo_id => nil).find_each do |day_candle|
      mongo_day_candle = MongoDayCandle.where(:symbol => day_candle.symbol, :trading_date => day_candle.trading_date).first
      unless mongo_day_candle
        mongo_day_candle = MongoDayCandle.new
      end

      mongo_day_candle.symbol = day_candle.symbol
      mongo_day_candle.trading_date = day_candle.trading_date
      mongo_day_candle.open = day_candle.open
      mongo_day_candle.high = day_candle.high
      mongo_day_candle.low = day_candle.low
      mongo_day_candle.close = day_candle.close
      mongo_day_candle.volume = day_candle.volume
      mongo_day_candle.stock_code = MongoStockCode.find(day_candle.stock_code.mongo_id)
      if mongo_day_candle.save
        day_candle.mongo_id = mongo_day_candle.id.to_s
        day_candle.save
      else
        puts "error on mongo_day_candle.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"



    # StockFirm
    sub_task_name = "converting stock_firm"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    StockFirm.find_each do |stock_firm|
      #StockCode.where(:mongo_id => nil).find_each do |stock_code|
      mongo_stock_firm = MongoStockFirm.where(:name => stock_firm.name).first
      unless mongo_stock_firm
        mongo_stock_firm = MongoStockFirm.new
      end
      mongo_stock_firm.name = stock_firm.name
      if mongo_stock_firm.save
        stock_firm.mongo_id = mongo_stock_firm.id.to_s
        stock_firm.save
      else
        puts "error on mongo_stock_code.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"




    # Recommendation
    sub_task_name = "converting recommendation"
    sub_start_time = Time.now
    puts "start #{sub_task_name} on #{sub_start_time}"
    Recommendation.find_each do |recommendation|
    #Recommendation.where(:mongo_id => nil).find_each do |recommendation|
      mongo_recommendation = MongoRecommendation.where(:in_date => recommendation.in_date,
                                                       :stock_code_id => if recommendation.stock_code then MongoStockCode.find(recommendation.stock_code.mongo_id).id else nil end,
                                                       :stock_firm_id => if recommendation.stock_firm then MongoStockFirm.find(recommendation.stock_firm.mongo_id).id else nil end,
                                                       :symbol => recommendation.symbol).first
      unless mongo_recommendation
        mongo_recommendation = MongoRecommendation.new
      end

      mongo_recommendation.in_date = recommendation.in_date
      mongo_recommendation.symbol = recommendation.symbol
      mongo_recommendation.stock_code = if recommendation.stock_code then MongoStockCode.find(recommendation.stock_code.mongo_id) else nil end
      mongo_recommendation.stock_firm = if recommendation.stock_firm then MongoStockFirm.find(recommendation.stock_firm.mongo_id) else nil end
      if mongo_recommendation.save
        recommendation.mongo_id = mongo_recommendation.id.to_s
        recommendation.save
      else
        puts "error on mongo_recommendation.save"
      end
    end

    sub_end_time = Time.now
    puts "ended #{sub_task_name} on #{sub_end_time}"
    puts "elapsed time of #{sub_task_name} : #{sub_end_time - sub_start_time}"




    end_time = Time.now
    puts "ended #{task_name} on #{end_time}"
    puts "elapsed time of #{task_name} : #{end_time - start_time}"
  end
end