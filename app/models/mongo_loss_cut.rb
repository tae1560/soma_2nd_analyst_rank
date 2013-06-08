class MongoLossCut
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "loss_cuts"

  field :percent, type: Float
  
  has_many :analyses, :class_name => "MongoAnalysis"

  validates_uniqueness_of :percent

  def self.initialize_data
    LossCut.create(:percent => 2)
    LossCut.create(:percent => 3)
    LossCut.create(:percent => 5)
    LossCut.create(:percent => 10)
    LossCut.create(:percent => -1)
  end
end