#coding:utf-8
class LossCut
  include Mongoid::Document

  attr_accessible :percent

  field :percent, type: Float

  has_many :analyses

  validates_uniqueness_of :percent

  def self.initialize_data
    LossCut.create(:percent => 2)
    LossCut.create(:percent => 3)
    LossCut.create(:percent => 5)
    LossCut.create(:percent => 10)
    LossCut.create(:percent => -1)
  end
end
