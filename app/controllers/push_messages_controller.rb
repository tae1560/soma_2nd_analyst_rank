class PushMessagesController < ApplicationController
  def index
    @push_messages = PushMessage.order("created_at DESC").all
  end
end
