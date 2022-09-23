# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    extra_sources = (Rails.env.development? && !ENV.key?('PRODUCTION_ASSET_CONFIG')) ? %i[ws] : []

    policy.default_src(:none)
    policy.base_uri(:self)
    policy.connect_src(:self, *extra_sources)
    policy.form_action(:self)
    policy.font_src(:self, :https, :data, *extra_sources)
    policy.img_src(:self, :https, :data, *extra_sources)
    policy.object_src(:none)
    policy.script_src(:self, *extra_sources)
    policy.style_src(:self, :https, :unsafe_inline, *extra_sources)
    policy.frame_ancestors(:self)
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator =
    ->(request) { request.session.id.to_s.presence || SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
