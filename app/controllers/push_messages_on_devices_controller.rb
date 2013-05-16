class PushMessagesOnDevicesController < ApplicationController
  def index
    @push_messages_on_devices = PushMessagesOnDevice.order("id DESC").all
  end
end
