class TestChannel < ApplicationCable::Channel
  def subscribed
    stream_from "test_channel"
    ActionCable.server.broadcast "test_channel", { message: "Hello from TestChannel!" }
  end
end