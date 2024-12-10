module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info "['ActionCable', 'Connection',] User: #{current_user.email}"
    end

    private
    def find_verified_user
      user = env['warden'].user
      if user
        Rails.logger.info "Action Cable: Connected as #{user.email}"
        user
      else
        Rails.logger.warn "Action Cable: Unauthorized connection attempt."
        reject_unauthorized_connection
      end
    end
  end
end
