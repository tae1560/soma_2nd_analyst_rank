class CreateRawRecommendations < ActiveRecord::Migration
  def change
    create_table :raw_recommendations do |t|
      t.string :in_dt
      t.string :cmp_nm_kor
      t.string :cmp_cd
      t.string :brk_nm_kor
      t.integer :brk_cd
      t.string :pf_nm_kor
      t.integer :pf_cd
      t.string :recomm_price
      t.string :recomm_rate
      t.integer :recommend_adj_price
      t.integer :pre_adj_price
      t.string :pre_dt
      t.integer :cnt
      t.string :reason_in
      t.string :file_nm
      t.string :anl_dt
      t.string :in_diff_reason

      t.integer :recommendation_id, :index => true

      t.timestamps
    end

    add_index :raw_recommendations, [:cmp_cd, :brk_cd, :pf_cd], :unique => true
  end
end
