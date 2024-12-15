# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", "User #{current_user.user.email}"
    end

    private

    def find_verified_user
      token = request.params[:cable_token] || request.query_parameters["cable_token"]
      Rails.logger.info "Cable token received: #{token}"
      Rails.logger.info "ActionCable: Attempting to authenticate with cable_token: #{token}"

      verified_user = ServerUser.find_by(cable_token: token)

      if verified_user
        Rails.logger.info "ActionCable: Authentication successful for user: #{verified_user.user.email}"
        verified_user
      else
        Rails.logger.warn "ActionCable: Authentication failed for cable_token: #{token.inspect}"
        reject_unauthorized_connection
      end
    rescue StandardError => e
      Rails.logger.error "ActionCable: Unexpected error during authentication - #{e.message}"
      reject_unauthorized_connection
    end
  end
end
