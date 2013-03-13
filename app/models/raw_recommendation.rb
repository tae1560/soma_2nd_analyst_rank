class RawRecommendation < ActiveRecord::Base
  attr_accessible :in_dt, :cmp_nm_kor, :cmp_cd, :brk_nm_kor, :brk_cd, :pf_nm_kor, :pf_cd, :recomm_price, :recomm_rate, :recommend_adj_price, :pre_adj_price, :pre_dt, :cnt, :reason_in, :file_nm, :anl_dt, :in_diff_reason

  belongs_to :recommendation

#  add_index :raw_recommendations, [:cmp_cd, :brk_cd, :pf_cd], :unique => true

  def self.duplicated? cmp_cd, brk_cd, pf_cd
    RawRecommendation.where(:cmp_cd => cmp_cd, :brk_cd => brk_cd, :pf_cd => pf_cd).exists?
  end

  def parse_and_save
    recommendation = self.recommendation
    unless recommendation
      recommendation = Recommendation.new
      self.recommendation = recommendation
    end

    recommendation.in_date = self.in_dt.to_datetime - 9.hours
    recommendation.symbol = self.cmp_cd

    # 증권사 instance
    stock_firm = StockFirm.find_or_create_instance self.brk_cd, self.brk_nm_kor
    if stock_firm
      recommendation.stock_firm = stock_firm
    end

    # stock code instance
    stock_code = StockCode.find_by_symbol self.cmp_cd
    if stock_code
      recommendation.stock_code = stock_code
    end

    unless recommendation.save
      puts "ERROR : recommendation.save is not working"
    end
  end
end