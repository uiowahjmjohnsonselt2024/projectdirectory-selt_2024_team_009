Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, "https://oaidalleapiprodscus.blob.core.windows.net"
    policy.object_src  :none
    policy.script_src  :self, :https, :unsafe_inline
    policy.style_src   :self, :https, :unsafe_inline
    policy.connect_src :self, :https, "ws://localhost:3000","ws://localhost:3001", "wss://localhost:3001","wss://localhost:3001","wss://localhost:3002",  "wss://shards-of-the-grid-team-09-ad424e75e121.herokuapp.com"
  end

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # config.content_security_policy_report_only = Rails.env.development?
end