# coding: utf-8
require 'tasks/day_candle_crawler'
require 'tasks/code_crawler'
require 'tasks/recommendation_crawler'

namespace :manager do
  task :calculate_simulation_daemon => :environment do
    loop do

      task_name = "manager:calculate_simulation"
      start_time = Time.now
      puts "start #{task_name} on #{start_time}"


      # 세금 + 증권사 수수료
      in_tax = (0.015) / 100
      out_tax = (0.3 + 0.015) / 100

      Simulation.find_each do |simulation|
        puts "simulation #{simulation.id} start"
        # getting params
        @stock_firm = simulation.stock_firm
        @total_asset = simulation.total_asset
        @invest_asset = simulation.invest_asset
        @recent_period = simulation.recent_period
        @keep_period = simulation.keep_period
        @loss_cut = simulation.loss_cut

        # getting require information
        @start_date = Time.now - @recent_period.days.days
        @recommendations = @stock_firm.recommendations.where("in_date > '#{@start_date}'").order("in_date DESC")


        # calculate
        @recommendation_prints = []
        @orders = []
        @recommendations.each do |recommendation|
          recommendation_print = Simulation.create_recommendation_print recommendation, @keep_period
          @recommendation_prints.push recommendation_print

          #  adding order
          if recommendation_print[:in_day_candle]
            order = {}
            order[:date] = recommendation_print[:in_day_candle].trading_date
            order[:type] = :in
            order[:recommendation_print] = recommendation_print
            @orders.push order
          end

          if recommendation_print[:out_day_candle]
            order = {}
            order[:date] = recommendation_print[:out_day_candle].trading_date
            order[:type] = :out
            order[:recommendation_print] = recommendation_print
            @orders.push order
          end
        end


        @rest_asset = @total_asset
        @profit_asset = 0
        @asset_history = {}
        @asset_history[Utility.utc_datetime_to_kor_str @start_date] = [0, [], @total_asset, 0]
        @current_stock_codes = []

        @orders.sort! {|x,y| x[:date] <=> y[:date]}
        @orders.each do |order|
          recommendation_print = order[:recommendation_print]
          if order[:type] == :in
            recommendation_print[:rest_asset] = @rest_asset
            if recommendation_print[:in_day_candle_open]
              real_invest_asset = [@invest_asset, @rest_asset].min
              recommendation_print[:volumn] = (real_invest_asset / recommendation_print[:in_day_candle_open] / (1+in_tax)).to_i
              recommendation_print[:in_price] = recommendation_print[:volumn] * recommendation_print[:in_day_candle_open] * (1+in_tax)
              if recommendation_print[:volumn] == 0
                recommendation_print[:state] = "잔액부족"
              else
                recommendation_print[:state] = "보유중"
              end

              recommendation_print[:in_price] = recommendation_print[:in_price].round
              @rest_asset -= recommendation_print[:in_price]

              # 가상 자산 history 저장
              in_day_candle = recommendation_print[:in_day_candle]
              if in_day_candle
                unless @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date]
                  @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date] = [0,[],0,0]
                end
                @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][0] -= recommendation_print[:in_price]
                @current_stock_codes.push recommendation_print
                @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][1] = @current_stock_codes.clone
                @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][2] = @rest_asset
              end
            end
          else
            if recommendation_print[:out_day_candle_close]
              recommendation_print[:out_price] = recommendation_print[:volumn] * recommendation_print[:out_day_candle_close] * (1-out_tax)

              recommendation_print[:out_price] = recommendation_print[:out_price].round
              @rest_asset += recommendation_print[:out_price]
              recommendation_print[:profit] = (recommendation_print[:out_price] - recommendation_print[:in_price])
              if recommendation_print[:volumn] > 0
                recommendation_print[:state] = "매도완료"
              end
              recommendation_print[:profit_ratio] = ((recommendation_print[:out_price] - recommendation_print[:in_price]) / recommendation_print[:in_price].to_f) * 100
              recommendation_print[:profit_ratio] = recommendation_print[:profit_ratio].round(2)

              # 가상 자산 history 저장
              out_day_candle = recommendation_print[:out_day_candle]
              if out_day_candle
                unless @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date]
                  @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date] = [0,[],0,0]
                end
                @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][0] += recommendation_print[:out_price]
                @current_stock_codes.delete recommendation_print
                @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][1] = @current_stock_codes.clone
                @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][2] = @rest_asset
              end
            end
          end
        end

        # caching : 시뮬레이션 필요가 있을경우만 하기
        #simulation = Simulation.find_or_create_by_filter(@stock_firm, @recent_period, @keep_period, @loss_cut, @total_asset, @invest_asset)
        #if simulation.is_need_to_update?
        #  virtual_asset = 0
        #  @recommendation_prints.each do |recommendation_print|
        #    # 최종 가상자산 계산
        #    if recommendation_print[:state] == "보유중"
        #      out_day_candle = recommendation_print[:stock_code].day_candles.order(:trading_date).last
        #      virtual_asset += recommendation_print[:volumn] * out_day_candle.open * (1-out_tax)
        #    end
        #  end
        #  virtual_asset = virtual_asset.round
        #  simulation.virtual_asset = virtual_asset
        #  simulation.balance_asset = @rest_asset
        #  simulation.last_modified = Time.now
        #  simulation.save!
        #end

        # 가상자산 계산
        for_cnt = 0
        total_cnt = @asset_history.count
        @asset_history.each do |k,v|
          virtual_asset = VirtualAsset.find_or_create(simulation, k.to_datetime)
          if virtual_asset.is_need_to_update?
            virtual_asset_sum = 0
            v[1].collect{|e| virtual_asset_sum += e[:volumn] * (1-out_tax) * e[:stock_code].day_candles.where("trading_date >= '#{Utility.kor_str_to_utc_datetime k}'").order(:trading_date).first.open}
            virtual_asset.last_modified = Time.now
            virtual_asset.amount = virtual_asset_sum
            virtual_asset.save!
          end

          v[3] = virtual_asset.amount
          for_cnt += 1
          if for_cnt % 5 == 0
            puts "simulation #{simulation.id} #{for_cnt} / #{total_cnt}"
          end
        end

        #@recommendation_prints.each do |recommendation_print|
        #  # 가상자산 입력
        #  if recommendation_print[:in_day_candle]
        #    asset_history = @asset_history[Utility.utc_datetime_to_kor_str recommendation_print[:in_day_candle].trading_date]
        #    recommendation_print[:in_profit_asset] = asset_history[2] + asset_history[3]
        #  end
        #
        #  if recommendation_print[:out_day_candle]
        #    asset_history = @asset_history[Utility.utc_datetime_to_kor_str recommendation_print[:out_day_candle].trading_date]
        #    recommendation_print[:out_profit_asset] = asset_history[2] + asset_history[3]
        #  end
        #end
      end # end of simulations

      # update 안된 가상자산은 제거
      VirtualAsset.where("last_modified IS NULL OR last_modified < '#{Time.now - 1.days}'").delete_all


      end_time = Time.now
      puts "ended #{task_name} on #{end_time}"
      puts "elapsed time of #{task_name} : #{end_time - start_time}"






      puts "daemon is sleeping"
      sleep 10
    end
  end
  task :calculate_simulation => :environment do
    task_name = "manager:calculate_simulation"
    start_time = Time.now
    puts "start #{task_name} on #{start_time}"


    # 세금 + 증권사 수수료
    in_tax = (0.015) / 100
    out_tax = (0.3 + 0.015) / 100

    Simulation.find_each do |simulation|
      puts "simulation #{simulation.id} start"
      # getting params
      @stock_firm = simulation.stock_firm
      @total_asset = simulation.total_asset
      @invest_asset = simulation.invest_asset
      @recent_period = simulation.recent_period
      @keep_period = simulation.keep_period
      @loss_cut = simulation.loss_cut

      # getting require information
      @start_date = Time.now - @recent_period.days.days
      @recommendations = @stock_firm.recommendations.where("in_date > '#{@start_date}'").order("in_date DESC")


      # calculate
      @recommendation_prints = []
      @orders = []
      @recommendations.each do |recommendation|
        recommendation_print = Simulation.create_recommendation_print recommendation, @keep_period
        @recommendation_prints.push recommendation_print

        #  adding order
        if recommendation_print[:in_day_candle]
          order = {}
          order[:date] = recommendation_print[:in_day_candle].trading_date
          order[:type] = :in
          order[:recommendation_print] = recommendation_print
          @orders.push order
        end

        if recommendation_print[:out_day_candle]
          order = {}
          order[:date] = recommendation_print[:out_day_candle].trading_date
          order[:type] = :out
          order[:recommendation_print] = recommendation_print
          @orders.push order
        end
      end


      @rest_asset = @total_asset
      @profit_asset = 0
      @asset_history = {}
      @asset_history[Utility.utc_datetime_to_kor_str @start_date] = [0, [], @total_asset, 0]
      @current_stock_codes = []

      @orders.sort! {|x,y| x[:date] <=> y[:date]}
      @orders.each do |order|
        recommendation_print = order[:recommendation_print]
        if order[:type] == :in
          recommendation_print[:rest_asset] = @rest_asset
          if recommendation_print[:in_day_candle_open]
            real_invest_asset = [@invest_asset, @rest_asset].min
            recommendation_print[:volumn] = (real_invest_asset / recommendation_print[:in_day_candle_open] / (1+in_tax)).to_i
            recommendation_print[:in_price] = recommendation_print[:volumn] * recommendation_print[:in_day_candle_open] * (1+in_tax)
            if recommendation_print[:volumn] == 0
              recommendation_print[:state] = "잔액부족"
            else
              recommendation_print[:state] = "보유중"
            end

            recommendation_print[:in_price] = recommendation_print[:in_price].round
            @rest_asset -= recommendation_print[:in_price]

            # 가상 자산 history 저장
            in_day_candle = recommendation_print[:in_day_candle]
            if in_day_candle
              unless @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date]
                @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date] = [0,[],0,0]
              end
              @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][0] -= recommendation_print[:in_price]
              @current_stock_codes.push recommendation_print
              @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][1] = @current_stock_codes.clone
              @asset_history[Utility.utc_datetime_to_kor_str in_day_candle.trading_date][2] = @rest_asset
            end
          end
        else
          if recommendation_print[:out_day_candle_close]
            recommendation_print[:out_price] = recommendation_print[:volumn] * recommendation_print[:out_day_candle_close] * (1-out_tax)

            recommendation_print[:out_price] = recommendation_print[:out_price].round
            @rest_asset += recommendation_print[:out_price]
            recommendation_print[:profit] = (recommendation_print[:out_price] - recommendation_print[:in_price])
            if recommendation_print[:volumn] > 0
              recommendation_print[:state] = "매도완료"
            end
            recommendation_print[:profit_ratio] = ((recommendation_print[:out_price] - recommendation_print[:in_price]) / recommendation_print[:in_price].to_f) * 100
            recommendation_print[:profit_ratio] = recommendation_print[:profit_ratio].round(2)

            # 가상 자산 history 저장
            out_day_candle = recommendation_print[:out_day_candle]
            if out_day_candle
              unless @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date]
                @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date] = [0,[],0,0]
              end
              @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][0] += recommendation_print[:out_price]
              @current_stock_codes.delete recommendation_print
              @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][1] = @current_stock_codes.clone
              @asset_history[Utility.utc_datetime_to_kor_str out_day_candle.trading_date][2] = @rest_asset
            end
          end
        end
      end

      # caching : 시뮬레이션 필요가 있을경우만 하기
      #simulation = Simulation.find_or_create_by_filter(@stock_firm, @recent_period, @keep_period, @loss_cut, @total_asset, @invest_asset)
      #if simulation.is_need_to_update?
      #  virtual_asset = 0
      #  @recommendation_prints.each do |recommendation_print|
      #    # 최종 가상자산 계산
      #    if recommendation_print[:state] == "보유중"
      #      out_day_candle = recommendation_print[:stock_code].day_candles.order(:trading_date).last
      #      virtual_asset += recommendation_print[:volumn] * out_day_candle.open * (1-out_tax)
      #    end
      #  end
      #  virtual_asset = virtual_asset.round
      #  simulation.virtual_asset = virtual_asset
      #  simulation.balance_asset = @rest_asset
      #  simulation.last_modified = Time.now
      #  simulation.save!
      #end

      # 가상자산 계산
      for_cnt = 0
      total_cnt = @asset_history.count
      @asset_history.each do |k,v|
        virtual_asset = VirtualAsset.find_or_create(simulation, k.to_datetime)
        if virtual_asset.is_need_to_update?
          virtual_asset_sum = 0
          v[1].collect{|e| virtual_asset_sum += e[:volumn] * (1-out_tax) * e[:stock_code].day_candles.where("trading_date >= '#{Utility.kor_str_to_utc_datetime k}'").order(:trading_date).first.open}
          virtual_asset.last_modified = Time.now
          virtual_asset.amount = virtual_asset_sum
          virtual_asset.save!
        end

        v[3] = virtual_asset.amount
        for_cnt += 1
        if for_cnt % 5 == 0
          puts "simulation #{simulation.id} #{for_cnt} / #{total_cnt}"
        end
      end

      #@recommendation_prints.each do |recommendation_print|
      #  # 가상자산 입력
      #  if recommendation_print[:in_day_candle]
      #    asset_history = @asset_history[Utility.utc_datetime_to_kor_str recommendation_print[:in_day_candle].trading_date]
      #    recommendation_print[:in_profit_asset] = asset_history[2] + asset_history[3]
      #  end
      #
      #  if recommendation_print[:out_day_candle]
      #    asset_history = @asset_history[Utility.utc_datetime_to_kor_str recommendation_print[:out_day_candle].trading_date]
      #    recommendation_print[:out_profit_asset] = asset_history[2] + asset_history[3]
      #  end
      #end
    end # end of simulations

    # update 안된 가상자산은 제거
    VirtualAsset.where("last_modified IS NULL OR last_modified < '#{Time.now - 1.days}'").delete_all


    end_time = Time.now
    puts "ended #{task_name} on #{end_time}"
    puts "elapsed time of #{task_name} : #{end_time - start_time}"
  end # end of task




  task :cron => :environment do
    start_time = Time.now
    puts "start manager:cron on #{start_time}"

    Rake::Task["crawler:stock_codes"].invoke
    Rake::Task["crawler:day_candles"].invoke
    Rake::Task["crawler:recommendations"].invoke
    Rake::Task["calculator:profit"].invoke

    # 실제 추천정보가 변화될때에 푸쉬
    if Recommendation.order("in_date DESC").first.in_date > Time.now - 2.days
      Utility.send_message_to_all "증권사 추천왕", "새로운 추천정보가 업데이트 되었습니다."
    end

    end_time = Time.now
    puts "ended manager:cron on #{end_time}"

    puts "elapsed time of manager:cron : #{end_time - start_time}"

  end

  task :push => :environment do
    # 실제 추천정보가 변화될때에 푸쉬
    if Recommendation.order("in_date DESC").first.in_date > Time.now - 2.days
      messages = []
      messages.push({:title => "증권사 추천왕", :message => "추천주 정보가 업데이트 되었습니다."})
      #messages.push({:title => "증권사 추천왕", :message => "새로운 종목이 추천되었습니다."})
      messages.push({:title => "증권사 추천왕", :message => "추천종목이 추가되었습니다."})
      Utility.send_message_to_all_with_ab_test messages
    end
  end

  task :re_push => :environment do
    Utility.send_remain_messages
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

#  association day_candle with stock_code
  task :fix_association => :environment do
    count = 0
    total_count = DayCandle.count
    DayCandle.find_each do |day_candle|
      unless day_candle.stock_code
        day_candle.stock_code = StockCode.where(:symbol => day_candle.symbol).first
        day_candle.save
      end

      count += 1
      if count % 1000 == 0
        puts "#{count} / #{total_count}"
      end
    end
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
      unless day_candle.stock_code
        day_candle.stock_code = StockCode.where(:symbol => day_candle.symbol).first
        day_candle.save
      end
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

  task :svm => :environment do
    task_name = "manager:svm"
    start_time = Time.now
    puts "start #{task_name} on #{start_time}"

    # setting learning data
    # code, day_candle 15, max percent, min percent, predict after 7 days
    end_date = Time.now - 1.years
    recommendations = Recommendation.where("in_date < '#{end_date}'")

    learning_data = []
    learning_results = []
    learning_results_bool = []
    recommendations.find_each do |recommendation|
      pre_day_candles = recommendation.stock_code.day_candles.where("trading_date < '#{recommendation.in_date}'")
      current_day_candle = recommendation.stock_code.day_candles.where("trading_date > '#{recommendation.in_date}'").order(:trading_date).first
      after_day_candle = recommendation.stock_code.day_candles.where("trading_date > '#{recommendation.in_date + 7.days}'").order(:trading_date).first

      if pre_day_candles.count > 15 and after_day_candle and current_day_candle
        learning_datum = []
        learning_datum.push recommendation.stock_firm.id

        # iterate pre_day_candles
        count = 0
        min_value = 99999999
        max_value = 0
        temp_data = []
        pre_day_candles.order("trading_date DESC").find_each do |pre_day_candle|
          if count > 15
            break
          end

          value = pre_day_candle.close
          min_value = [min_value, value].min
          max_value = [max_value, value].max
          temp_data.push value
          count += 1
        end

        mdd = max_value - min_value
        temp_data.each do |temp_datum|
          learning_datum.push (temp_datum - min_value) / mdd.to_f
        end

        # find min,max percent
        min_percent = 0
        max_percent = 0
        if min_value.to_f > 0
          min_percent = (current_day_candle.close - min_value) / min_value.to_f
        end

        if max_value.to_f > 0
          max_percent = (current_day_candle.close - max_value) / max_value.to_f
        end


        learning_datum.push min_percent
        learning_datum.push max_percent

        puts learning_datum.inspect
        learning_data.push learning_datum

        profit = 0
        if current_day_candle.close > 0
          profit = (after_day_candle.close - current_day_candle.close) / current_day_candle.close.to_f
        end

        puts "#{current_day_candle.close} #{after_day_candle.close} #{profit}"

        if profit > 0
          learning_results_bool.push 1
        else
          learning_results_bool.push -1
        end

        #[43, 0.7294117647058823, 0.6470588235294118, 1.0, 0.35294117647058826, 0.08235294117647059, 0.18823529411764706, 0.041176470588235294, 0.029411764705882353, 0.07058823529411765, 0.08823529411764706, 0.047058823529411764, 0.0, 0.058823529411764705, 0.1588235294117647, 0.11764705882352941, 0.2, -0.18248945147679324, -0.3067978533094812]
        #3875 40300 1

        learning_results.push profit * 10000

        #[43, 0.7294117647058823, 0.6470588235294118, 1.0, 0.35294117647058826, 0.08235294117647059, 0.18823529411764706, 0.041176470588235294, 0.029411764705882353, 0.07058823529411765, 0.08823529411764706, 0.047058823529411764, 0.0, 0.058823529411764705, 0.1588235294117647, 0.11764705882352941, 0.2, -0.18248945147679324, -0.3067978533094812]
        #3875 40300 9.4

      end
    end

    require 'libsvm'
# This library is namespaced.
    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new
    parameter.cache_size = 200 # in megabytes
    parameter.eps = 0.001 # tolerance of termination criterion
    parameter.c = 10 # C parameter (for C_SVC, Epsilon_SVR and Nu_SVR)
    #examples = [ [1,0,1], [-1,0,-1] ].map {|ary| Libsvm::Node.features(ary) }
    #labels = [10, -5]
    examples = learning_data.map {|ary| Libsvm::Node.features(ary) }
    labels = learning_results
    problem.set_examples(labels, examples)
    model = Libsvm::Model.train(problem, parameter)
    puts model.inspect
    model.save("model3.svm")

    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new
    parameter.cache_size = 200 # in megabytes
    parameter.eps = 0.001 # tolerance of termination criterion
    parameter.c = 10 # C parameter (for C_SVC, Epsilon_SVR and Nu_SVR)
    #examples = [ [1,0,1], [-1,0,-1] ].map {|ary| Libsvm::Node.features(ary) }
    #labels = [10, -5]
    examples = learning_data.map {|ary| Libsvm::Node.features(ary) }
    labels = learning_results_bool
    problem.set_examples(labels, examples)
    model = Libsvm::Model.train(problem, parameter)
    puts model.inspect
    model.save("model4.svm")

    #model = Libsvm::Model.load("model2.svm")
    #pred = model.predict(Libsvm::Node.features(43, 0.7294117647058823, 0.6470588235294118, 1.0, 0.35294117647058826, 0.08235294117647059, 0.18823529411764706, 0.041176470588235294, 0.029411764705882353, 0.07058823529411765, 0.08823529411764706, 0.047058823529411764, 0.0, 0.058823529411764705, 0.1588235294117647, 0.11764705882352941, 0.2, -0.18248945147679324, -0.3067978533094812))
    #puts "Example [1, 1, 1] - Predicted #{pred}"

    end_time = Time.now
    puts "ended #{task_name} on #{end_time}"
    puts "elapsed time of #{task_name} : #{end_time - start_time}"
  end

  task :svm_predict => :environment do
    task_name = "manager:svm_predict"
    start_time = Time.now
    puts "start #{task_name} on #{start_time}"


    end_date = Time.now - 1.years
    recommendations = Recommendation.where("in_date > '#{end_date}' AND in_date < '#{Time.now - 1.month}'")

    result_array = []
    recommendations.order("in_date DESC").find_each do |recommendation|
      puts "recommendation"
      pre_day_candles = recommendation.stock_code.day_candles.where("trading_date < '#{recommendation.in_date}'")
      current_day_candle = recommendation.stock_code.day_candles.where("trading_date > '#{recommendation.in_date}'").order(:trading_date).first
      after_day_candle = recommendation.stock_code.day_candles.where("trading_date > '#{recommendation.in_date + 7.days}'").order(:trading_date).first



      if pre_day_candles.count > 15 and after_day_candle and current_day_candle
        learning_datum = []

        learning_datum.push recommendation.stock_firm.id

        # iterate pre_day_candles
        count = 0
        min_value = 99999999
        max_value = 0
        temp_data = []
        pre_day_candles.order("trading_date DESC").find_each do |pre_day_candle|
          if count > 15
            break
          end

          value = pre_day_candle.close
          min_value = [min_value, value].min
          max_value = [max_value, value].max
          temp_data.push value
          count += 1
        end

        mdd = max_value - min_value
        temp_data.each do |temp_datum|
          learning_datum.push (temp_datum - min_value) / mdd.to_f
        end

        # find min,max percent
        min_percent = 0
        max_percent = 0
        if min_value.to_f > 0
          min_percent = (current_day_candle.close - min_value) / min_value.to_f
        end

        if max_value.to_f > 0
          max_percent = (current_day_candle.close - max_value) / max_value.to_f
        end


        learning_datum.push min_percent
        learning_datum.push max_percent

        #puts learning_datum.inspect
        #learning_data.push learning_datum

        profit = 0
        if current_day_candle.close > 0
          profit = (after_day_candle.close - current_day_candle.close) / current_day_candle.close.to_f
        end

        puts "#{recommendation.id} #{current_day_candle.close} #{after_day_candle.close} #{profit}"

        #if profit > 0
        #  learning_results_bool.push 1
        #else
        #  learning_results_bool.push 0
        #end

        #[43, 0.7294117647058823, 0.6470588235294118, 1.0, 0.35294117647058826, 0.08235294117647059, 0.18823529411764706, 0.041176470588235294, 0.029411764705882353, 0.07058823529411765, 0.08823529411764706, 0.047058823529411764, 0.0, 0.058823529411764705, 0.1588235294117647, 0.11764705882352941, 0.2, -0.18248945147679324, -0.3067978533094812]
        #3875 40300 1

        #learning_results.push profit * 10000

        #[43, 0.7294117647058823, 0.6470588235294118, 1.0, 0.35294117647058826, 0.08235294117647059, 0.18823529411764706, 0.041176470588235294, 0.029411764705882353, 0.07058823529411765, 0.08823529411764706, 0.047058823529411764, 0.0, 0.058823529411764705, 0.1588235294117647, 0.11764705882352941, 0.2, -0.18248945147679324, -0.3067978533094812]
        #3875 40300 9.4

        model = Libsvm::Model.load("model4.svm")
        pred = model.predict(Libsvm::Node.features(learning_datum))
        #puts "[#{learning_datum.inspect}] - Predicted #{pred / 10000.to_f}    real profit : #{profit}"
        #puts "[Predicted #{pred / 10000.to_f}    real profit : #{profit}"
        puts "[Predicted #{pred}    real profit : #{profit > 0 ? 1 : 0}"

        #result_array.push [pred / 10000.to_f, profit]
        result_array.push [pred, profit > 0 ? 1 : 0]

      end

    end
    puts result_array.to_json

    File.open("result2.txt", "w") do |aFile|
      aFile.puts result_array.to_json
    end

    end_time = Time.now
    puts "ended #{task_name} on #{end_time}"
    puts "elapsed time of #{task_name} : #{end_time - start_time}"
  end
end