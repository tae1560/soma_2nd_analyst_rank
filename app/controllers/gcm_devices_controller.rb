class GcmDevicesController < ApplicationController
  def create
    if params["regId"]
      @gcm_device = Gcm::Device.find_or_create_by_registration_id(:registration_id => "#{params["regId"]}")

      if @gcm_device.save
        render :json => {"result" => "success"}
      else
        render :json => {"result" => "failed", "message" => "save error", "full_messages" => @gcm_device.errors.full_messages}
      end
    else
      render :json => {"result" => "failed", "message" => "needed regId params", "full_messages" => "needed regId params"}
    end
  end
end
