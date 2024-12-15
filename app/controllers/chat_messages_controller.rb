class ChatMessagesController < ApplicationController
  before_action :set_server

  def create
    @chat_message = @server.chat_messages.new(chat_message_params.merge(user: current_user))

    if @chat_message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @server, notice: 'Message was sent successfully.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to @server, alert: 'Failed to send the message.' }
      end
    end
  end

  private

  def set_server
    @server = Server.find(params[:server_id])
  end

  def chat_message_params
    params.require(:chat_message).permit(:content)
  end
end
