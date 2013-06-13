class Api::ApiController < ApplicationController
  def find_user_by_auth_token
    unless params[:auth_token]
      render :json => {"status" => 400, "message" => "MissingRequiredQueryParameter - auth_token"}
      return false
    end

    @user = User.where(:authentication_token => params[:auth_token]).first
    unless @user
      render :json => {"status" => 403, "message" => "AuthenticationFailed - user not found"}
      return false
    end
  end
end
