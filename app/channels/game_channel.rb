class GameChannel < ApplicationCable::Channel
  include Turbo::Streams::ActionHelper

  def subscribed
    stream_for server
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Class method for broadcasting state
  def self.broadcast_state(server, partial:, locals:)
    turbo_stream_message = ApplicationController.render(
      partial: partial,
      locals: locals,
      formats: [:html]
    )
    broadcast_to(server, { turbo_stream: turbo_stream_message })
  end

  private

  def server
    Server.find(params[:server_id])
  end
end
