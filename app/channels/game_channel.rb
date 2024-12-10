class GameChannel < ApplicationCable::Channel
  def subscribed
    @server = Server.find(params[:server_id])
    stream_for @server
    Rails.logger.info "User #{current_user.email} subscribed to GameChannel for Server #{@server.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    Rails.logger.info "User #{current_user.email} unsubscribed from GameChannel for Server #{@server.id}"
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
