class Utility
  def self.kor_str_to_utc_datetime str
    str.to_date.to_datetime - 9.hours
  end
  def self.utc_datetime_to_kor_str datetime
    datetime.in_time_zone("Seoul").to_date
  end

  def self.send_message_to_all title, message
    push_message = PushMessage.create(:title => title, :message => message)


    Gcm::Device.find_each do |device|
      push_messages_on_device = PushMessagesOnDevice.create
      push_messages_on_device.push_message = push_message
      push_messages_on_device.gcm_device = device
      push_messages_on_device.push_time = Time.now
      push_messages_on_device.save!

      notification = Gcm::Notification.new
      notification.device = device
      notification.collapse_key = "updates_available"
      notification.delay_while_idle = false
      notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => push_messages_on_device.id}}
      notification.save!
    end
    Gcm::Notification.send_notifications
  end

  #def self.send_message_to_device device, title, message
  #  push_message = PushMessage.create(:title => title, :message => message)
  #
  #  push_messages_on_device = PushMessagesOnDevice.create
  #  push_messages_on_device.push_message = push_message
  #  push_messages_on_device.gcm_device = device
  #  push_messages_on_device.save!
  #
  #  notification = Gcm::Notification.new
  #  notification.device = device
  #  notification.collapse_key = "updates_available"
  #  notification.delay_while_idle = false
  #  notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => push_messages_on_device.id}}
  #  notification.save!
  #
  #  Gcm::Notification.send_notifications
  #end
end