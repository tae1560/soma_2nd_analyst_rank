class KeepPeriod < ActiveRecord::Base
  attr_accessible :name, :days

  has_many :analyses
end
