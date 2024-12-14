# app/channels/turbo/streams_channel.rb
module Turbo
  class StreamsChannel < ApplicationCable::Channel
    def subscribed
      stream_for "Turbo::StreamsChannel"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end
  end
end
