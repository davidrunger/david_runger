# frozen_string_literal: true

class FetchIpInfoForRequest
  include Memery
  prepend ApplicationWorker

  LOCAL_IPS = %w[::1 127.0.0.1].map(&:freeze).freeze

  def perform(request_id)
    request = Request.find(request_id)
    write_location_info(request)
  end

  private

  def write_location_info(request)
    ip = request.ip
    return if ip.in?(LOCAL_IPS)

    ip_info = Rails.cache.fetch(cache_key(ip), expires_in: 4.weeks) { ip_info_from_api(ip) }
    request.update!(ip_info)
  end

  def cache_key(ip)
    "ip-info:#{ip}"
  end

  memoize \
  def ip_info_from_api(ip)
    Rails.logger.info("Querying ip-api.com for info about IP address '#{ip}'")
    # we'd have to pay to use https :( so just use http
    raw_ip_info_from_api = Faraday.json_connection.get("http://ip-api.com/json/#{ip}").body
    isp, city, state, country = raw_ip_info_from_api.values_at(*%w[isp city region countryCode])

    {
      location: [city, state, country].compact_blank.join(', '),
      isp:,
    }
  end
end
