#coding:utf-8
class KeepPeriod
  include Mongoid::Document

  attr_accessible :name, :days

  field :name, type: String
  field :days, type: Integer

  has_many :analyses

  validates_uniqueness_of :name, :scope => :days

  def self.initialize_data
    KeepPeriod.create(:name => "7일", :days => 7)
    KeepPeriod.create(:name => "15일", :days => 15)
    KeepPeriod.create(:name => "30일", :days => 30)
    KeepPeriod.create(:name => "3개월", :days => 91)
    KeepPeriod.create(:name => "6개월", :days => 182)
    KeepPeriod.create(:name => "12개월", :days => 365)
  end
end
