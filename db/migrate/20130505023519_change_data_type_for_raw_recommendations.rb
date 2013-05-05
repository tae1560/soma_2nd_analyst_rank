class ChangeDataTypeForRawRecommendations < ActiveRecord::Migration
  def up
    change_table :raw_recommendations do |t|
      t.change :reason_in, :text
    end
  end

  def down
    change_table :raw_recommendations do |t|
      t.change :reason_in, :string
    end
  end
end
