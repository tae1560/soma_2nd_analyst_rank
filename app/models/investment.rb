# coding: utf-8
class Investment < ActiveRecord::Base
  attr_accessible :start_date, :total_asset, :invest_asset

  belongs_to :user
  belongs_to :stock_firm
  belongs_to :keep_period
  belongs_to :recent_period
  belongs_to :loss_cut

  #  user가 가지고 있음
  #  analysis와 비슷하게 증권사, recent, keep, loss_cut 지님
  #  시작날짜, 전체자산, 매번 투자자산 정할 수 있음
  #  analysis : 증권사, recent, keep, loss_cut 지님 + 계산값들
end
