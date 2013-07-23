class Simulation < ActiveRecord::Base
  attr_accessible :total_asset, :invest_asset, :last_modified, :balance_asset, :virtual_asset
  belongs_to :stock_firm
  belongs_to :recent_period
  belongs_to :keep_period
  belongs_to :loss_cut
  has_many :virtual_assets

  def self.find_or_create_by_filter stock_firm, recent_period, keep_period, loss_cut, total_asset, invest_asset
    simulation = Simulation.where(:stock_firm_id => stock_firm.id,
                    :recent_period_id => recent_period.id,
                    :keep_period_id => keep_period.id,
                    :loss_cut_id => loss_cut.id,
                    :total_asset => total_asset,
                    :invest_asset => invest_asset).first

    unless simulation
      simulation = Simulation.new(:total_asset => total_asset,
                                   :invest_asset => invest_asset)
      simulation.stock_firm = stock_firm
      simulation.recent_period = recent_period
      simulation.keep_period = keep_period
      simulation.loss_cut = loss_cut
      simulation.save!
    end
    return simulation
  end

  def is_need_to_update?
    !self.last_modified or Time.now - self.last_modified > 1.days
  end
end
