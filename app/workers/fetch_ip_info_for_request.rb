# frozen_string_literal: true

class FetchIpInfoForRequest
  extend Memoist
  prepend ApplicationWorker

  class BlankIpInfo < StandardError ; end

  LOCAL_IPS = %w[::1 127.0.0.1].map(&:freeze).freeze

  def perform(request_id)
    request = Request.find(request_id)
    write_location_info(request)
  end

  private

  def write_location_info(request)
    ip = request.ip
    return if ip.blank? || (Rails.env.development? && ip.in?(LOCAL_IPS))

    ip_info = Rails.cache.read(cache_key(ip)) || ip_info_from_api(ip)
    fail(BlankIpInfo, "Blank IP info for IP '#{ip}'") if ip_info.blank? # trigger Sidekiq retry

    request.update!(ip_info)
  end

  def cache_key(ip)
    "ip-info:#{ip}"
  end

  memoize \
  def ip_info_from_api(ip)
    Rails.logger.info("Querying ip-api.com for info about IP address '#{ip}'")
    raw_ip_info_from_api = Faraday.json_connection.get("http://ip-api.com/json/#{ip}").body
    isp, city, state, country = raw_ip_info_from_api.values_at(*%w[isp city region countryCode])

    parsed_ip_info = {
      location: [city, state, country].reject(&:blank?).join(', '),
      isp: isp,
    }

    Rails.cache.write(cache_key(ip), parsed_ip_info, expires_in: 4.weeks)

    parsed_ip_info
  end
end
