class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:game_id]}"
  end

  def unsubscribed
    # Cleanup if necessary
  end

  def speak(data)
    message = Message.create!(
      content: data['message'],
      user: current_user,
      game_id: params[:game_id]
    )
    ActionCable.server.broadcast("chat_#{params[:game_id]}", message: render_message(message))
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'messages/message', locals: { message: message })
  end
end
