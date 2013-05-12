class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def save_session_by_regId regId
    if regId and regId.length > 0
      @gcm_device = Gcm::Device.find_or_create_by_registration_id(:registration_id => "#{regId}")

      if @gcm_device.save
        session["device_id"] = @gcm_device.id
      end
    end
  end

  def record_push_metric push_messages_on_device_id_string
    if push_messages_on_device_id_string and push_messages_on_device_id_string.length > 0
      push_messages_on_device_id = push_messages_on_device_id_string.to_i

      push_messages_on_device = PushMessagesOnDevice.find(push_messages_on_device_id)
      if push_messages_on_device
        push_messages_on_device.receive_time = Time.now
        push_messages_on_device.save!
      end
    end
  end
end
