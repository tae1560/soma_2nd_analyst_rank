class LossCut < ActiveRecord::Base
  attr_accessible :percent, :mongo_id

  has_many :analyses
end
