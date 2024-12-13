class TurboStreamsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "turbo_streams_#{params[:server_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end