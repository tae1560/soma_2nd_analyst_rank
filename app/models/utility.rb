class Utility
  def self.kor_str_to_utc_datetime str
    str.to_date.to_datetime - 9.hours
  end
  def self.utc_datetime_to_kor_str datetime
    begin
      datetime.in_time_zone("Seoul").to_date
    rescue
      datetime
    end

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
    Utility.send_remain_messages
  end

  # param : [{:title => "title", :message => "message"}]
  def self.send_message_to_all_with_ab_test title_message_pairs
    number_of_case = title_message_pairs.count

    push_messages = []

    title_message_pairs.each do |title_message_pair|
      push_message = PushMessage.create(:title => title_message_pair[:title], :message => title_message_pair[:message])

      push_messages.push push_message
    end


    #Gcm::Device.find_each do |device|
    count = (rand * number_of_case).ceil - 1
    Gcm::Device.all.shuffle.each do |device|
      push_message = push_messages[count]
      push_messages_on_device = PushMessagesOnDevice.create
      push_messages_on_device.push_message = push_message
      push_messages_on_device.gcm_device = device
      push_messages_on_device.push_time = Time.now
      push_messages_on_device.save!

      notification = Gcm::Notification.new
      notification.device = device
      notification.collapse_key = "updates_available"
      notification.delay_while_idle = false
      notification.data = {:registration_ids => ["#{device.registration_id}"], :data => {:message_text => push_message.message, :title_text => push_message.title, :notification_id => push_messages_on_device.id}}
      notification.save!

      count += 1
      if count >= number_of_case
        count = 0
      end
    end
    Gcm::Notification.send_notifications
  end

  def self.send_message_to_device device, title, message
    push_message = PushMessage.create(:title => title, :message => message)

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

    Utility.send_remain_messages
  end

  def self.send_remain_messages
    while Gcm::Notification.where(:sent_at => nil).count > 0
      begin
        puts "started send notification  current_count : #{Gcm::Notification.where(:sent_at => nil).count}"
        Gcm::Notification.send_notifications
      rescue
        puts "errored send notification"
        sleep 3
      end
    end
    puts "ended send notification"
  end
end