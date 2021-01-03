# frozen_string_literal: true

# This is a monkeypatch to respect the `redirect_uri` query param in an OAuth flow in tests.
#
# If provided in the real OAuth flow, then our `omniauth` gem will pass such a query param to
# Google, and Google will respect that query param, responding with a redirect to the specified URL.
#
# However, when `test_mode` is `true` in tests, the `redirect_uri` query param isn't respected,
# which makes for wrongful test failures (false positive failures). Instead, `test_mode` has this
# simplistic behavior: "A request to `/auth/provider` will redirect immediately to
# `/auth/provider/callback`." (https://github.com/omniauth/omniauth/wiki/Integration-Testing) This
# monkeypatch fixes that deficiency.

module Monkeypatches::OmniAuth::Strategies::GoogleOauth2
  def callback_path
    redirect_uri = Rack::Utils.parse_nested_query(@env['QUERY_STRING'])['redirect_uri']
    if redirect_uri.present?
      URI.parse(redirect_uri).path
    else
      super
    end
  end
end

OmniAuth::Strategies::GoogleOauth2.prepend(Monkeypatches::OmniAuth::Strategies::GoogleOauth2)
