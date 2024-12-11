module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.email
    end

    private

    def find_verified_user
      token = request.params[:cable_token] || request.query_parameters["cable_token"]
      Rails.logger.info "ActionCable: Attempting to authenticate with cable_token: #{token.inspect}"

      # Directly query the ServerUser model
      if (current_server_user = ServerUser.find_by(cable_token: token))
        Rails.logger.info "ActionCable: Authentication successful for user: #{current_server_user.user.email}"
        current_server_user
      else
        Rails.logger.warn "ActionCable: Authentication failed for cable_token: #{token.inspect}"
        reject_unauthorized_connection
      end
    end
  end
end
