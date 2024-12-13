module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", "User #{current_user.user.email}" # Access associated User's email
    end

    private

    def find_verified_user
      token = request.params[:cable_token] || request.query_parameters["cable_token"]
      token2 = cookies.signed[:cable_token]
      #Rails.logger.info "ActionCable: Attempting to authenticate with cable_token: #{token.inspect}"
      #Rails.logger.info "Sessonstoken: Attempting to authenticate with cable_token: #{token2.inspect}"
      # Find the ServerUser by cable_token
      server_user = ServerUser.find_by(cable_token: token)

      if server_user&.user # Ensure the associated User exists
        #Rails.logger.info "ActionCable: Authentication successful for user: #{server_user.user.email}"
        server_user # Return the ServerUser instance
      else
        #Rails.logger.warn "ActionCable: Authentication failed for cable_token: #{token.inspect}"
        reject_unauthorized_connection
      end
    rescue StandardError => e
      #Rails.logger.error "ActionCable: Unexpected error during authentication - #{e.message}"
      reject_unauthorized_connection
    end
  end
end
