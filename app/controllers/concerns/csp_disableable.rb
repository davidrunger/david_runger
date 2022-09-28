# frozen_string_literal: true

module CspDisableable
  extend ActiveSupport::Concern

  included do
    # (somewhat unsafe) workarounds until https://github.com/hotwired/turbo/issues/ 294 is resolved
    before_action :dont_set_csp_nonce
    content_security_policy do |policy|
      policy.script_src(:self, :https, :unsafe_inline)
    end
  end

  private

  def dont_set_csp_nonce
    request.env['action_dispatch.content_security_policy_nonce_directives'] = []
  end
end
