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
    wp-includes
    wp-login
    wp1
    wp2
  ].map(&:freeze)).freeze
  PENTESTERS_PREFIX = 'pentesters-'
  PENTESTING_FINDTIME = 1.day.freeze

  # Limit all IPs to 60 requests per clock minute
  # rubocop:disable Style/SymbolProc
  throttle('req/ip', limit: 60, period: 1.minute) do |request|
    request.ip
  end
  # rubocop:enable Style/SymbolProc

  class << self
    extend Memoist

    memoize \
    def blocked_ips
      # rescue because sometimes the database might not even exist yet, e.g. during tests
      Set.new((IpBlock.pluck(:ip) rescue []).map(&:freeze)).freeze
    end

    def blocked_path?(request)
      fragments = request.path.split(%r{/|\.|\?})
      fragments.map!(&:presence)
      fragments.compact!
      fragments.any? do |fragment|
        fragment.downcase.in?(Rack::Attack::BANNED_PATH_FRAGMENTS)
      end && !Rails.application.routes.recognize_path_with_request(
        ActionDispatch::Request.new(request.env),
        request.path,
        {},
        raise_on_missing: false,
      )
    end
  end
end

Rails.application.reloader.to_prepare do
  # Trigger memoization during bootup (rather than waiting until first request is made).
  # Do it within a `reloader.to_prepare` block to avoid warning about autoloading constants.
  Rack::Attack.blocked_ips
end

# Block IPs requesting Wordpress paths etc.
# After 2 blocked requests in 1 day, block all requests from that IP.
Rack::Attack.blocklist('fail2ban pentesters') do |request|
  # `filter` returns truthy value if request fails the checks or if it's from a previously banned IP
  Rack::Attack::Fail2Ban.filter(
    "#{Rack::Attack::PENTESTERS_PREFIX}#{request.ip}",
    maxretry: 2,
    findtime: Rack::Attack::PENTESTING_FINDTIME,
    bantime: 1.day, # this is just until next dyno restart, when `IpBlock` we create will permaban
  ) do
    is_blocked_path = Rack::Attack.blocked_path?(request)

    if is_blocked_path
      # store request data in Redis so that we can store a block reason if/when we create an IpBlock
      IpBlocks::StoreRequestBlockInRedis.new(ip: request.ip, path: request.path).run!
    end

    is_blocked_path
  end
end

Rack::Attack.blocklist('blocked IPs') do |request|
  request.ip.in?(Rack::Attack.blocked_ips)
end

# this notification gets triggered via `InstrumentFail2BanEvent` monkeypatch
ActiveSupport::Notifications.subscribe(
  'fail2banned.rack_attack',
) do |_name, _start, _finish, _request_id, payload|
  ip = payload[:discriminator].sub(Rack::Attack::PENTESTERS_PREFIX, '')
  # do this asynchronously so that all blocked request data will be registered in Redis first
  CreateIpBlock.perform_in(5.seconds, ip)
end
