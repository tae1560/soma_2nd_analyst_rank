class Analysis < ActiveRecord::Base
  attr_accessible :earning_average, :earning_variance, :count_winner, :count_loser

  belongs_to :stock_firm
  belongs_to :keep_period
  belongs_to :recent_period
  belongs_to :loss_cut
end
