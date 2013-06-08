class MongoAnalysis
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "analyses"

  field :earning_average, type: Float
  field :earning_variance, type: Float
  field :count_winner, type: Integer
  field :count_loser, type: Integer
  
  belongs_to :stock_firm, :class_name => "MongoStockFirm", :inverse_of => :analyses
  belongs_to :keep_period, :class_name => "MongoKeepPeriod", :inverse_of => :analyses
  belongs_to :recent_period, :class_name => "MongoRecentPeriod", :inverse_of => :analyses
  belongs_to :loss_cut, :class_name => "MongoLossCut", :inverse_of => :analyses

  validates_uniqueness_of :stock_firm_id, :scope => [:keep_period_id, :recent_period_id, :loss_cut_id]
end