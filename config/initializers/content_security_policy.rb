# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https, "https://cdn.jsdelivr.net", :unsafe_inline, -> { "'nonce-#{@csp_nonce}'" }
    policy.style_src   :self, :https, "https://cdn.jsdelivr.net", :unsafe_inline, -> { "'nonce-#{@csp_nonce}'" }
    # Allow external CDNs for Bootstrap
    policy.connect_src :self, :https
  end


  # Allow nonces for inline styles and scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Enable CSP violation reporting for debugging
  # config.content_security_policy_report_only = Rails.env.development?
end