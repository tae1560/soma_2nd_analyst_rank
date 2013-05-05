class Analysis < ActiveRecord::Base
  attr_accessible :earning_average, :earning_variance

  belongs_to :stock_firm
  belongs_to :keep_period
  belongs_to :recent_period
end