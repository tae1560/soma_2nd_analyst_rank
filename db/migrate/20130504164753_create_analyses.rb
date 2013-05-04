class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.float :earning_average
      t.float :earning_variance
      t.integer :stock_firm_id, :index => true

      t.timestamps
    end
  end
end
