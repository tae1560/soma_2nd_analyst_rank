class AddReasonOnRecommendation < ActiveRecord::Migration
  def up
    add_column :recommendations, :reason_in, :text

    total = Recommendation.count
    i = 0
    Recommendation.find_each do |recommendation|
      raw_recommendation = recommendation.raw_recommendation
      if raw_recommendation
        recommendation.reason_in = raw_recommendation.reason_in
        recommendation.save
      end

      i += 1
      if i % 100 == 0
        puts "migrating recommendation records (#{i}/#{total})"
      end
    end
  end

  def down
    remove_column :recommendations, :reason_in
  end
end
