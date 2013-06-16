class AddIndexToRecommendations < ActiveRecord::Migration
  def change
    add_index :recommendations, [:stock_code_id, :stock_firm_id, :in_date, :symbol], :unique => true, :name => "recommendation_unique_index"
  end
end
