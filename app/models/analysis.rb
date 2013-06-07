class Analysis
  include Mongoid::Document

  attr_accessible :earning_average, :earning_variance

  field :earning_average, type: Float
  field :earning_variance, type: Float

  belongs_to :stock_firm, :inverse_of => :analyses
  belongs_to :keep_period, :inverse_of => :analyses
  belongs_to :recent_period, :inverse_of => :analyses
  belongs_to :loss_cut, :inverse_of => :analyses

  validates_uniqueness_of :stock_firm_id, :scope => [:keep_period_id, :recent_period_id, :loss_cut_id]
end
