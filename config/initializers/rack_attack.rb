# frozen_string_literal: true

class Rack::Attack
  BANNED_PATH_FRAGMENTS = Set.new(%w[
    env
    old-wp
    passwd
    php
    phpformbuilder
    phpmyadmin
    phpmyadmin
    plugins
    wordpress
    wp
    wp-admin
    wp-login
    wp1
    wp2
  ])

  # Limit all IPs to 60 requests per clock minute
  # rubocop:disable Style/SymbolProc
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end
  # rubocop:enable Style/SymbolProc
end

# Block IPs requesting Wordpress paths etc.
# After 2 blocked requests in a day, block all requests from that IP for 1 year.
Rack::Attack.blocklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails the checks or if it's from a previously banned IP
  Rack::Attack::Fail2Ban.filter(
    "pentesters-#{req.ip}",
    maxretry: 2,
    findtime: 1.day,
    bantime: 4.weeks, # memcached struggles to handle values much longer than this
  ) do
    fragments = req.path.split(%r{/|\.|\?})
    fragments.map!(&:presence)
    fragments.compact!
    fragments.any? do |fragment|
      fragment.downcase.in?(Rack::Attack::BANNED_PATH_FRAGMENTS)
    end
  end
end
