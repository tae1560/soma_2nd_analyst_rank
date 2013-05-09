class Utility
  def self.kor_str_to_utc_datetime str
    str.to_date.to_datetime - 9.hours
  end
  def self.utc_datetime_to_kor_str datetime
    datetime.in_time_zone("Seoul").to_date
  end

  def self.send_message_to_all title, message
    Gcm::Device.find_each do |device|
      notification = Gcm::Notification.new
      notification.device = device
      notification.collapse_key = "updates_available"
      notification.delay_while_idle = false
      notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => notification.id}}
      notification.save!
      notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => notification.id}}
      notification.save!
    end
    Gcm::Notification.send_notifications
  end

  def self.send_message_to_device device, title, message
    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = "updates_available"
    notification.delay_while_idle = false
    notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => notification.id}}
    notification.save!
    notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => notification.id}}
    notification.save!

    Gcm::Notification.send_notifications
  end
end