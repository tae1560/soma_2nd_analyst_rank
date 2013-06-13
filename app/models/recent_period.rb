class RecentPeriod < ActiveRecord::Base
  attr_accessible :name, :days, :mongo_id

  has_many :analyses
end
