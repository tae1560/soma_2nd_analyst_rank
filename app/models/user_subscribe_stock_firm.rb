class UserSubscribeStockFirm
  include Mongoid::Document

  # attr_accessible :title, :body
  belongs_to :user, :reverse_of => :user_subscribe_stock_firms
  belongs_to :stock_firm, :reverse_of => :user_subscribe_stock_firms

  validates_uniqueness_of :user_id, :scope => :stock_firm_id
end
