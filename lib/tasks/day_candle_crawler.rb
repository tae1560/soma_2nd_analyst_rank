# coding: utf-8
require 'nokogiri'
require 'open-uri'

def crawl_all_chart

  # 하루가 지난 데이터는 필요한 양만큼 새로 받음
  StockCode.find_each do |stock_code|
    #crawl_chart(stock_code, stock_code[:symbol])

    if stock_code[:crawl_date] == nil
      term_secs = Time.now - Time.parse("120101");
      term_days = (term_secs / 1.days).round + 1
    else
      term_secs = Time.now - stock_code[:crawl_date];
      term_days = (term_secs / 1.days).round + 1
    end
    if term_days > 1
      crawl_chart(stock_code, stock_code[:symbol], term_days)
    end

    stock_code[:crawl_date] = Time.now
    stock_code.save
  end
end

def crawl_chart (stock_code, code = 000270, count = 2500)
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
    trading_date = date.to_datetime - 9.hours


    unless DayCandle.duplicated?(symbol, trading_date)
      begin
        d = DayCandle.new(:symbol => symbol, :trading_date => trading_date, :o => o, :h => h, :l => l, :c => c, :v => v)
        d.stock_code = stock_code
        unless d.save
          puts "ERROR : DayCandle #{d.inspect} did not saved!"
        end
      rescue
        puts $!
      end
    else
      puts "Duplicated! #{symbol}, #{trading_date.in_time_zone("Seoul")}"
    end
  end
end