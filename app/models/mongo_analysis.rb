class MongoAnalysis
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "analyses"

  field :earning_average, type: Float
  field :earning_variance, type: Float
  field :count_winner, type: Integer
  field :count_loser, type: Integer
  
  belongs_to :stockfirm
  belongs_to :keepperiod
  belongs_to :recentperiod
  belongs_to :losscut

end