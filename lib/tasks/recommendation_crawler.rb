# coding: utf-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'iconv'
#require 'tasks/chart_crawler'

def crawl_recommend
  curPage = 1
  #endDt = "20130302"
  endDt = (Time.now + 1.days).to_date.to_s.gsub("-","")
  perPage = 20
  startDt = "20100101"

  url = "http://recommend.finance.naver.com/Home/GetInOut?brkCd=0&curPage=#{curPage}&endDt=#{endDt}&perPage=#{perPage}&pfCd=0&proc=1&startDt=#{startDt}"
  puts url

  doc = open(url).read
  result = JSON.parse(doc)
  data = result["data"]
  puts "total row : #{data[0]["TOTROW"]}"

  # 전체 데이터 수로 전체 페이지 수 계산
  total_row = data[0]["TOTROW"]
  total_page = (total_row / perPage + 1).to_i

  while curPage <= total_page
    # "IN_DT":"2013/02/26",
    # "CMP_CD":"034230",
    # "BRK_NM_KOR":"한양증권",
    # "BRK_CD":15,
    url = "http://recommend.finance.naver.com/Home/GetInOut?brkCd=0&curPage=#{curPage}&endDt=#{endDt}&perPage=#{perPage}&pfCd=0&proc=1&startDt=#{startDt}"
    puts url
    doc = open(url).read
    result = JSON.parse(doc)
    data = result["data"]
    data.each do |row|
      in_dt = row["IN_DT"]
      cmp_cd = row["CMP_CD"]
      brk_nm_kor = row["BRK_NM_KOR"]
      brk_cd = row["BRK_CD"]

      recommendation_date = in_dt.to_datetime
      recommendation_date -= 9.hours


      # 증권사 instance
      stock_firm = StockFirm.find_or_create_instance brk_cd, brk_nm_kor

      # stock code instance
      stock_code = StockCode.find_by_symbol cmp_cd

      # day candle by symbol and trading date
      day_candle = nil
      if stock_code
        day_candle = stock_code.day_candles.where(:trading_date => recommendation_date).first
      end

      if day_candle and stock_firm
        recommendation = stock_firm.recommendations.where(:day_candle_id => day_candle.id).first
        if recommendation
          # duplicated by day candle and stock firm
          puts "duplicated by day candle and stock firm : day_candle - #{day_candle.inspect} , stock_firm - #{stock_firm.inspect}"
          puts "recommendation : #{recommendation.inspect}"
          puts "recommendation_date : #{recommendation_date}, cmp_cd : #{cmp_cd}"
        else
          recommendation = Recommendation.new(:in_dt => recommendation_date, :cmp_cd => cmp_cd, :brk_nm_kor => brk_nm_kor, :brk_cd => brk_cd)
          recommendation.stock_code = stock_code
          recommendation.day_candle = day_candle
          recommendation.stock_firm = stock_firm
          unless recommendation.save
            "ERROR : recommendation.save not worked"
          end
        end
      end

    end


    curPage += 1
  end

  #pg_no = 1
  #
  #while true
  #
  #  # 각 데이터 튜플
  #  odd_tuples = doc.xpath("//tr[@bgcolor='#E5E5E5']")
  #  even_tuples = doc.xpath("//tr[@bgcolor='#EDEDED']")
  #
  #  if even_tuples.size==1 and odd_tuples.size==0
  #    puts "ENDED"
  #    break
  #  end
  #
  #  odd_tuples.each do |tuple|
  #    parsing_each_tuple(tuple)
  #  end
  #
  #  even_tuples.each do |tuple|
  #    parsing_each_tuple(tuple)
  #  end
  #
  #  pg_no += 1
  #end

  ## 업종별 URL 얻어오기
  #upjong_links = doc.xpath("//div[@id='contentarea_left']/table[@class='type_1']//a[contains(@href,'/sise/sise_group_detail.nhn')]/@href")
  #
  ## 각 업종별로 종목 Code 얻어오기
  #upjong_links.each do |upjong|
  #  # parsing bug
  #  urlString = upjong.to_s.gsub("upjong=", "upjong&no=")
  #
  #  # 업종 페이지에서 code 포함된 링크 얻어오기
  #  subdoc = Nokogiri::XML(open("http://finance.naver.com/" + urlString), nil, 'euc-kr')
  #  code_links = subdoc.xpath("//div[@id='contentarea']//a[contains(@href,'main.nhn?code=')]")
  #
  #  # 각 code 링크
  #  code_links.each do |code_link|
  #    # <a href="/item/main.nhn?code=004780">대륙제관</a>
  #    company_name_node = code_link.xpath("./text()")
  #    company = Iconv.iconv("utf8", "euc-kr", company_name_node.to_s);
  #
  #    code_url = code_link.xpath("./@href").to_s
  #    code = code_url[/code=(......)/, 1]
  #    store_code(code, company)
  #
  #  end
  #end
end


#def parsing_each_tuple(tuple)
#  columns = tuple.css("td")
#
#  if columns.size == 6
#    # 발행기관코드	종목명	영문종목명	표준코드	단축코드	시장구분
#    # institution_code, name, eng_name, standard_code, symbol, market_type
#    institution_code = columns[0].inner_text
#    name = columns[1].inner_text
#    eng_name = columns[2].inner_text
#    standard_code = columns[3].inner_text
#    short_code = columns[4].inner_text
#    market_type = columns[5].inner_text
#
#    if market_type.include? "상장"
#      if !(market_type.include? "폐지")
#        symbol = short_code[-6, 6]
#        store_code(institution_code, name, eng_name, standard_code, short_code, market_type, symbol)
#      end
#    end
#  else
#    puts "ERROR : columns.size is not 6 but #{columns.size}"
#  end
#end

#def store_code (institution_code, name, eng_name, standard_code, short_code, market_type, symbol)
#  # attr_accessible :issue_code, :symbol, :name, :eng_name, :standard_code, :short_code, :market_type, :crawl_date
#  #unless StockCode.duplicated?(symbol)
#  #  begin
#  #    StockCode.create(:institution_code => institution_code, :name => name, :eng_name => eng_name,
#  #      :standard_code => standard_code, :short_code => short_code, :market_type => market_type, :symbol => symbol)
#  #  rescue
#  #    puts $!
#  #  end
#  #  puts "saved #{symbol}, #{name}"
#  #else
#  #  puts "Duplicated! #{symbol}, #{name}"
#  #  #s = StockCode.where(:symbol => symbol).first
#  #  #s[:name] = name
#  #  #s[:eng_name] = eng_name
#  #  #s.save
#  #end
#end
