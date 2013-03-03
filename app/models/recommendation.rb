class Recommendation < ActiveRecord::Base
  attr_accessible :in_dt, :cmp_cd, :brk_nm_kor, :brk_cd

  belongs_to :stock_code
  belongs_to :day_candle
  belongs_to :stock_firm
end
