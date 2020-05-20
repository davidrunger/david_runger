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
  ].map(&:freeze)).freeze

  # Limit all IPs to 60 requests per clock minute
  # rubocop:disable Style/SymbolProc
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end
  # rubocop:enable Style/SymbolProc

  class << self
    attr_reader :blocked_ips

    def cache_blocked_ips_in_memory
      @blocked_ips = Set.new(
        (IpBlock.select(:id, :ip).find_each.map { |ip_block| ip_block.ip.freeze } rescue []),
      ).freeze
    end
  end
end

# Block IPs requesting Wordpress paths etc.
# After 2 blocked requests in 1 day, block all requests from that IP for 4 weeks.
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

Rack::Attack.cache_blocked_ips_in_memory
Rack::Attack.blocklist('blocked IPs') do |req|
  req.ip.in?(Rack::Attack.blocked_ips)
end
