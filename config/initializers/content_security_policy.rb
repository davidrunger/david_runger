# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    extra_sources = []
    if Rails.env.development?
      # :nocov:
      extra_sources << 'https://davidrunger.com' # allow assets from production for local prerenders
      if !ENV.key?('PRODUCTION_ASSET_CONFIG')
        extra_sources << 'ws://localhost:3036' # vite live reloading websockets server
        extra_sources << 'http://localhost:3036' # vite asset server
      end
      # :nocov:
    end

    policy.default_src(:none)
    policy.base_uri(:self)
    policy.connect_src(:self, *extra_sources)
    policy.manifest_src(:self, *extra_sources)
    policy.form_action(:self, 'https://accounts.google.com')
    policy.font_src(:self, :https, :data, *extra_sources)
    policy.img_src(:self, :https, :data, *extra_sources)
    policy.object_src(:none)
    policy.script_src(:self, *extra_sources)
    policy.style_src(:self, :https, :unsafe_inline, *extra_sources)
    policy.frame_ancestors(:self)
    policy.report_uri('/api/csp_reports')
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator =
    ->(request) { request.session.id.to_s.presence || SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
