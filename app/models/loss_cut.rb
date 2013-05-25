class LossCut < ActiveRecord::Base
  attr_accessible :percent

  has_many :analyses
end
