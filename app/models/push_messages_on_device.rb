class PushMessagesOnDevice < ActiveRecord::Base
  attr_accessible :push_time, :receive_time

    belongs_to :push_message
    belongs_to :gcm_device, :class_name => Gcm::Device
end
