# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide HTTP permissions policy. For further
# information see: https://developers.google.com/web/updates/2018/06/feature-policy

Rails.application.config.permissions_policy do |f|
  # Unfortunately, there's not a good way to disable all features
  # (https://github.com/w3c/webappsec-permissions-policy/issues/ 189), so we'll just disable the
  # subset of features provided by Rails (below).
  f.camera(:none)
  f.gyroscope(:none)
  f.microphone(:none)
  f.usb(:none)
  f.fullscreen(:none)
  f.payment(:none)
end
