class RecommendationsController < ApplicationController
  def index
    @recommendations = Recommendation.limit(100)
  end
end
