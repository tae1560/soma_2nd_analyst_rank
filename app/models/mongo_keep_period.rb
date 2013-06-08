class MongoKeepPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "keep_periods"

  field :name, type: String
  field :days, type: Integer
  
  has_many :analyses

end