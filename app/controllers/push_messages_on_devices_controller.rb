class PushMessagesOnDevicesController < ApplicationController
  def index
    @push_messages_on_devices = PushMessagesOnDevices.all
  end
end
