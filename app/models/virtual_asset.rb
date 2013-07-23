class VirtualAsset < ActiveRecord::Base
  attr_accessible :date, :amount, :last_modified
  belongs_to :simulation

  def self.find_or_create simulation, date
    virtual_asset = simulation.virtual_assets.where(:date => date).first
    unless virtual_asset
      virtual_asset = VirtualAsset.new(:date => date)
      virtual_asset.simulation = simulation
      virtual_asset.save!
    end
    return virtual_asset
  end

  def is_need_to_update?
    !self.last_modified or Time.now - self.last_modified > 1.days
  end
end
