#coding:utf-8
class RecommendationsController < ApplicationController
  def index
    @recommendations = Recommendation.order("in_date DESC").paginate(:page => params[:page], :per_page => 30)

    unless session[:recent_period_id]
      session[:recent_period_id] = RecentPeriod.last.id
    end

    unless session[:keep_period_id]
      session[:keep_period_id] = KeepPeriod.last.id
    end

    if params[:recent_period_id]
      session[:recent_period_id] = params[:recent_period_id].to_i
    end

    if params[:keep_period_id]
      session[:keep_period_id] = params[:keep_period_id].to_i
    end

    @recent_period = RecentPeriod.find(session[:recent_period_id])
    @keep_period = KeepPeriod.find(session[:keep_period_id])

    @base_date_string = "최근 #{@recent_period.name} 추천을 #{@keep_period.name} 동안 유지할 때"
  end
end
