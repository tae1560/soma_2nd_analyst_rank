#coding:utf-8
class CreateKeepPeriods < ActiveRecord::Migration
  def up
    create_table :keep_periods do |t|
      t.string :name
      t.integer :days

      t.timestamps
    end

    add_column :analyses, :keep_period_id, :integer, :index => true

    KeepPeriod.create(:name => "7일", :days => 7)
    KeepPeriod.create(:name => "15일", :days => 15)
    KeepPeriod.create(:name => "30일", :days => 30)
    KeepPeriod.create(:name => "3개월", :days => 91)
    KeepPeriod.create(:name => "6개월", :days => 182)
    KeepPeriod.create(:name => "12개월", :days => 365)
  end

  def down
    remove_column :analyses, :keep_period_id

    drop_table :keep_periods
  end
end
