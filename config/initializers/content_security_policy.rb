# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  # Allow disabling CSP in development because it breaks Vue devtools in Firefox.
  if Rails.env.local? && ENV.key?('DISABLE_CSP')
    # :nocov:
    next
    # :nocov:
  end

  config.content_security_policy do |policy|
    extra_sources = []
    extra_connect_sources = []
    # :nocov:
    if Rails.env.development? || (Rails.env.test? && !ENV.key?('CI'))
      extra_sources << DavidRunger::CANONICAL_URL # allow assets from prod for local prerenders
      extra_connect_sources << 'ws://localhost:3000' # actioncable connections
      local_hostname = ENV.fetch('LOCAL_HOSTNAME', nil)
      if local_hostname.present?
        extra_connect_sources << "ws://#{local_hostname}:3000" # actioncable w/ local hostname
      end

      if !ENV.key?('PRODUCTION_ASSET_CONFIG')
        extra_sources << 'ws://localhost:3036' # vite live reloading websockets server
        extra_sources << 'http://localhost:3036' # vite asset server

        if (vite_ruby_host = ENV.fetch('VITE_RUBY_HOST', nil)).present?
          extra_connect_sources << "ws://#{vite_ruby_host}:3036" # vite server at e.g. 0.0.0.0
          extra_connect_sources << "http://#{vite_ruby_host}:3036" # vite server at e.g. 0.0.0.0
        end

        if local_hostname.present?
          extra_sources << "ws://#{local_hostname}:3036" # vite live reload server w/ local hostname
          extra_sources << "http://#{local_hostname}:3036" # vite asset server w/ local hostname
        end
      end
    elsif Rails.env.production?
      extra_connect_sources << "wss://#{DavidRunger::CANONICAL_DOMAIN}" # for actioncable websockets
    end
    # :nocov:

    policy.default_src(:none)
    policy.base_uri(:self)
    policy.connect_src(:self, *extra_sources, *extra_connect_sources)
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
