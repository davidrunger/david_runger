require 'ipaddr'
require 'resolv'
require 'uri'

class SafeExternalHttpFetcher
  class UnsafeUrlError < StandardError; end

  # IPv6 global-unicast allocations currently occupy 2000::/3. Review this
  # allowlist if IANA allocates global-unicast space outside that range.
  IPV6_GLOBAL_UNICAST_RANGE = IPAddr.new('2000::/3').freeze

  # IANA special-purpose ranges that are not ordinary global-unicast
  # destinations. Keep redirect handling disabled: if it is enabled later,
  # each redirect target must be resolved, validated, and pinned separately.
  PROHIBITED_IPV4_RANGES = %w[
    0.0.0.0/8
    10.0.0.0/8
    100.64.0.0/10
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.0.0.0/24
    192.0.2.0/24
    192.31.196.0/24
    192.52.193.0/24
    192.88.99.0/24
    192.168.0.0/16
    192.175.48.0/24
    198.18.0.0/15
    198.51.100.0/24
    203.0.113.0/24
    224.0.0.0/4
    240.0.0.0/4
  ].map { IPAddr.new(it) }.freeze
  PROHIBITED_IPV6_RANGES = %w[
    ::/96
    64:ff9b:1::/48
    100::/64
    2001::/23
    2001:2::/48
    2001:db8::/32
    2001:10::/28
    2002::/16
    3fff::/20
    5f00::/16
    fc00::/7
    fe80::/10
    ff00::/8
  ].map { IPAddr.new(it) }.freeze

  def get(url, timeout:)
    uri = http_uri(url)
    pinned_address = resolved_address(uri.hostname)

    Faraday.new do |connection|
      connection.adapter(:net_http) do |http|
        # Net::HTTP retains its original address for Host, SNI, and TLS
        # certificate validation, while ipaddr= pins the TCP connection.
        http.ipaddr = pinned_address.to_s
      end
    end.get do |request|
      request.url(uri)
      request.options.timeout = timeout
    end
  end

  private

  def http_uri(url)
    uri = URI.parse(url)

    unless uri.is_a?(URI::HTTP) && !uri.hostname.to_s.empty? && uri.userinfo.nil?
      raise(UnsafeUrlError, "Unsafe external URL: #{url.inspect}")
    end

    uri
  rescue URI::InvalidURIError
    raise(UnsafeUrlError, "Unsafe external URL: #{url.inspect}")
  end

  def resolved_address(hostname)
    addresses = Resolv.getaddresses(hostname).map { IPAddr.new(it) }
    raise(UnsafeUrlError, "Could not resolve external hostname: #{hostname}") if addresses.empty?

    if addresses.any? { prohibited_address?(it) }
      raise(UnsafeUrlError, "Prohibited external address for #{hostname}")
    end

    addresses.first
  rescue IPAddr::InvalidAddressError, Resolv::ResolvError, SocketError
    raise(UnsafeUrlError, "Could not resolve external hostname: #{hostname}")
  end

  def prohibited_address?(address)
    if address.ipv4_mapped?
      prohibited_address?(address.native)
    elsif address.ipv4?
      PROHIBITED_IPV4_RANGES.any? { it.include?(address) }
    elsif address.ipv6?
      prohibited_ipv6_address?(address)
    else
      raise(UnsafeUrlError, "Unsupported resolved address: #{address}")
    end
  end

  def prohibited_ipv6_address?(address)
    if IPV6_GLOBAL_UNICAST_RANGE.include?(address)
      PROHIBITED_IPV6_RANGES.any? { it.include?(address) }
    else
      true
    end
  end
end
