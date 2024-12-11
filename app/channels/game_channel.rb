class GameChannel < ApplicationCable::Channel
  def subscribed
    @server = Server.find(params[:server_id])
    stream_for @server
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Turbo Stream helper for broadcasting updates
  def self.broadcast_turbo_stream(server, target:, html:)
    broadcast_to(
      server,
      type: "turbo_stream",
      target: target,
      html: html
    )
  end
end
