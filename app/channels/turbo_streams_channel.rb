class TurboStreamsChannel < ApplicationCable::Channel
  def subscribed
    @server = Server.find(params[:server_id])
    stream_for @server
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
