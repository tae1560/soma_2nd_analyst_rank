#coding:utf-8
class CreateRecentPeriods < ActiveRecord::Migration
  def up
    create_table :recent_periods do |t|
      t.string :name
      t.integer :days

      t.timestamps
    end

    add_column :analyses, :recent_period_id, :integer, :index => true
    add_index :analyses, [:keep_period_id, :recent_period_id], :name => 'index_by_keep_period_id_and_recent_period_id'

    RecentPeriod.create(:name => "1개월", :days => 30)
    RecentPeriod.create(:name => "2개월", :days => 60)
    RecentPeriod.create(:name => "3개월", :days => 91)
    RecentPeriod.create(:name => "6개월", :days => 182)
    RecentPeriod.create(:name => "12개월", :days => 365)
    RecentPeriod.create(:name => "전체", :days => -1)
  end

  def down
    remove_index :analyses, :name => 'index_by_keep_period_id_and_recent_period_id'
    remove_column :analyses, :recent_period_id

    drop_table :recent_periods
  end
end
