# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
Rails.application.config.action_dispatch.cookies_serializer = :json

# Specify the SameSite level protection for the cookies
# Valid options are :none, :lax, and :strict.
Rails.application.config.action_dispatch.cookies_same_site_protection = :lax

# Specify cookie expiration time (since otherwise defaults to "Session" cookie expiry, which is
# cleared in Safari after quitting the browser)
Rails.application.config.session_store(:cookie_store, expire_after: 1.year)
