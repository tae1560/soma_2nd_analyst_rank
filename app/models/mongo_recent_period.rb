#coding:utf-8
class MongoRecentPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "recent_periods"

  field :name, type: String
  field :days, type: Integer
  
  has_many :analyses, :class_name => "MongoAnalysis"

  validates_uniqueness_of :name, :scope => :days

  def self.initialize_data
    RecentPeriod.create(:name => "1개월", :days => 30)
    RecentPeriod.create(:name => "2개월", :days => 60)
    RecentPeriod.create(:name => "3개월", :days => 91)
    RecentPeriod.create(:name => "6개월", :days => 182)
    RecentPeriod.create(:name => "12개월", :days => 365)
    RecentPeriod.create(:name => "전체", :days => -1)
  end

end