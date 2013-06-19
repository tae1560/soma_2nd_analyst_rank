class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def save_session_by_regId regId
    if regId and regId.length > 0
      @gcm_device = Gcm::Device.find_or_create_by_registration_id(:registration_id => "#{regId}")
      @gcm_device.updated_at = Time.now

      if @gcm_device.save
        session["device_id"] = @gcm_device.id

        push_messages_on_device = @gcm_device.push_messages_on_devices.order(:push_time).last
        unless push_messages_on_device.receive_time
          push_messages_on_device.receive_time = Time.now
          push_messages_on_device.save!
        end
      end
    end
  end

  def record_push_metric push_messages_on_device_id_string
    if push_messages_on_device_id_string and push_messages_on_device_id_string.length > 0
      push_messages_on_device_id = push_messages_on_device_id_string.to_i

      if push_messages_on_device_id > 0
        begin
          push_messages_on_device = PushMessagesOnDevice.find(push_messages_on_device_id)

          if push_messages_on_device
            push_messages_on_device.receive_time = Time.now
            push_messages_on_device.save!
          end
        rescue
          puts "rescue"
          bt = $!.backtrace * "\n  "
          ($stderr << "error: #{$!.inspect}\n  #{bt}\n").flush
        end
      end
    end
  end

  def analysis_filtering_with_parameters params
    unless session[:recent_period_id]
      if RecentPeriod.where(:days => 182).last
        session[:recent_period_id] = RecentPeriod.where(:days => 182).last.id
      else
        session[:recent_period_id] = RecentPeriod.last.id
      end
    end

    unless session[:keep_period_id]
      if RecentPeriod.where(:days => 91).last
        session[:keep_period_id] = KeepPeriod.where(:days => 30).last.id
      else
        session[:keep_period_id] = KeepPeriod.last.id
      end
    end

    unless session[:loss_cut_id]
      if LossCut.where(:percent => 5).last
        session[:loss_cut_id] = LossCut.where(:percent => 5).last.id
      else
        session[:loss_cut_id] = LossCut.last.id
      end
    end

    if params[:recent_period_id]
      session[:recent_period_id] = params[:recent_period_id].to_i
    end

    if params[:keep_period_id]
      session[:keep_period_id] = params[:keep_period_id].to_i
    end

    if params[:loss_cut_id]
      session[:loss_cut_id] = params[:loss_cut_id].to_i
    end

    @recent_period = RecentPeriod.find_by_id(session[:recent_period_id])
    @keep_period = KeepPeriod.find_by_id(session[:keep_period_id])
    @loss_cut = LossCut.find_by_id(session[:loss_cut_id])
  end
end
