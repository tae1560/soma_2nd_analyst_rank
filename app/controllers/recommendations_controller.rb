#coding:utf-8
class RecommendationsController < ApplicationController
  def index
    analysis_filtering_with_parameters params

    @recommendations = Recommendation.order("in_date DESC").paginate(:page => params[:page], :per_page => 30)

    @base_date_string = "최근 #{@recent_period.name} 추천을 #{@keep_period.name} 동안 유지할 때"

    save_session_by_regId params["regId"]
    record_push_metric params["notification_id"]

    respond_to do |format|
      format.html
      format.js
    end
  end
end
