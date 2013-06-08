#coding:utf-8
class MongoKeepPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "keep_periods"

  field :name, type: String
  field :days, type: Integer
  
  has_many :analyses, :class_name => "MongoAnalysis"

  validates_uniqueness_of :name, :scope => :days

  def self.initialize_data
    MongoKeepPeriod.create(:name => "7일", :days => 7)
    MongoKeepPeriod.create(:name => "15일", :days => 15)
    MongoKeepPeriod.create(:name => "30일", :days => 30)
    MongoKeepPeriod.create(:name => "3개월", :days => 91)
    MongoKeepPeriod.create(:name => "6개월", :days => 182)
    MongoKeepPeriod.create(:name => "12개월", :days => 365)
  end
end