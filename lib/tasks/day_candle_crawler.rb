# coding: utf-8
require 'nokogiri'
require 'open-uri'

def crawl_all_chart

  # 하루가 지난 데이터는 필요한 양만큼 새로 받음
  StockCode.find_each do |stock_code|
    #crawl_chart(stock_code, stock_code[:symbol])

    day_candle = stock_code.day_candles.order(:trading_date).last

    if day_candle and day_candle.trading_date
      term_secs = Time.now - day_candle.trading_date
      term_days = (term_secs / 1.days).round + 1
    else
      term_secs = Time.now - Time.parse("120101")
      term_days = (term_secs / 1.days).round + 1
    end

    if term_days > 2
      crawl_chart(stock_code[:symbol], term_days)
    end

    stock_code[:crawl_date] = Time.now
    stock_code.save
  end

  puts "ENDED"
end

def crawl_chart (code = 000270, count = 2500)
  puts "http://fchart.stock.naver.com/sise.nhn?symbol=#{code}&timeframe=day&count=#{count}&requestType=0"
  doc = Nokogiri::XML(
      open("http://fchart.stock.naver.com/sise.nhn?symbol=#{code}&timeframe=day&count=#{count}&requestType=0"), nil,
      'euc-kr')
  chartdata = doc.css("protocol chartdata")

  #chartdata[0].attributes.each do |key, value|
  #puts "#{key}, #{value}"
  #end

  if chartdata[0]
    symbol = chartdata[0]["symbol"]
  end

  items = chartdata.css("item")

  items.each do |item|
    date, o, h, l, c, v = item["data"].split("|")
    #puts "#{symbol}, #{date}, #{o}, #{h}, #{l}, #{c}, #{v}"

    # 데이터 체크
    if date == nil or o == nil or h == nil or l == nil or c == nil or v == nil
      puts "WARN : something is nil => #{item["data"]}"
    end

    unless RawDayCandle.duplicated?(symbol, date)
      begin
        d = RawDayCandle.new(:symbol => symbol, :date => date, :o => o, :h => h, :l => l, :c => c, :v => v)
        unless d.save
          puts "ERROR : RawDayCandle #{d.inspect} did not saved!"
        end

        if d
          d.parse_and_save
        end
      rescue
        puts $!
      end
    else
      puts "Duplicated! #{symbol}, #{date}"
    end
  end
end