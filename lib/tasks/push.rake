# coding: utf-8
task :push => :environment do
  begin

    require 'gcm_on_rails_tasks'

    puts "push started"

    puts configatron.gcm_on_rails.api_url
    puts configatron.gcm_on_rails.api_key
    puts configatron.gcm_on_rails.app_name
    puts configatron.gcm_on_rails.delivery_format

    device_token = "APA91bHCivJe4V6KxMFT_ZhXWovKmJUqrJL8ZVitopnEasSd_QwBI5UNzScvRv5cKwhEO3-G58Aj9cLKLjTbsmWITgmga6nZ-PpOFi3No-vfpQM4zWLdyhuabx1mQp0Q6XOFzmkR-nxr3FF_XiI3gHbbQfB3gYfUjg"
    device = Gcm::Device.find_or_create_by_registration_id(:registration_id => "#{device_token}")
    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = "updates_available"
    notification.delay_while_idle = false
    notification.data = {:registration_ids => ["#{device_token}"], :data => {:message_text => "message_test", :title_text => "title_test", :notification_id => notification.id}}
    notification.save!
    notification.data = {:registration_ids => ["#{device_token}"], :data => {:message_text => "message_test", :title_text => "title_test", :notification_id => notification.id}}
    notification.save!
    puts notification.data
    Gcm::Notification.send_notifications
    #send_notifications

  rescue MissingSourceFile => e
    puts e.message
  end


end