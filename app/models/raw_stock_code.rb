# coding: utf-8
class RawStockCode < ActiveRecord::Base
  # 발행기관코드	종목명	영문종목명	표준코드	단축코드	시장구분
  attr_accessible :institution_code, :name, :eng_name, :standard_code, :short_code, :market_type

  belongs_to :stock_code

  def self.duplicated? standard_code
    RawStockCode.where(:standard_code => standard_code).exists?
  end

  def parse_and_save
    if self.market_type.include? "상장"
      if !(self.market_type.include? "폐지")
        stock_code = self.stock_code
        unless stock_code
          stock_code = StockCode.new
          self.stock_code = stock_code
        end

        stock_code.name = self.name
        stock_code.eng_name = self.eng_name
        stock_code.symbol = self.short_code[-6, 6]

        unless stock_code.save
          puts "ERROR : stock_code.save is not working"
        end
      end
    end
  end
end
