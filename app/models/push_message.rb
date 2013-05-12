class PushMessage < ActiveRecord::Base
  attr_accessible :title, :message

  has_many :push_messages_on_devices
  has_many :gcm_devices, :class_name => Gcm::Device, :through => :push_messages_on_devices
end
