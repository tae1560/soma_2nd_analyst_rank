class ModifyKeyOfRawRecommendation < ActiveRecord::Migration
  def up
    remove_index :raw_recommendations, [:cmp_cd, :brk_cd, :pf_cd]
    add_index :raw_recommendations, [:in_dt, :cmp_cd, :brk_cd, :pf_cd], :unique => true, :name => 'by_in_dt_and_cds'
  end

  def down
    remove_index :raw_recommendations, :name => 'by_in_dt_and_cds'
    add_index :raw_recommendations, [:cmp_cd, :brk_cd, :pf_cd], :unique => true
  end
end
