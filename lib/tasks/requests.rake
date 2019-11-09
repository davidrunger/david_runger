# frozen_string_literal: true

class RequestIpLookup
  extend Memoist

  # the API we are using limits us to 100 IPs per request (and 150 req/min)
  MAX_LOCATIONS_TO_FETCH = 100

  def write_location_info_for_requests
    requests_needing_ip_info.find_each do |request|
      ip_data = ip_info[request.ip]
      next if ip_data.blank?

      request.update!(ip_data)
      puts "Updated Request #{request.id} with data #{ip_data}"
    end

    true
  end

  private

  memoize \
  def ip_info
    ip_info_from_cache.merge(ip_info_from_api)
  end

  memoize \
  def ip_info_from_cache
    info = {}

    ips_needing_info.each do |ip|
      value_from_cache = Rails.cache.read(cache_key(ip))
      info[ip] = value_from_cache if value_from_cache.present?
    end

    info
  end

  memoize \
  def ip_info_from_api
    info = {}

    ips_still_needing_info = ips_needing_info - ip_info_from_cache.keys
    ips_to_look_up_in_api = ips_still_needing_info.first(MAX_LOCATIONS_TO_FETCH)

    puts "About to lookup location data for these IP addresses: #{ips_to_look_up_in_api}"
    api_response_ip_infos =
      begin
        HTTParty.post(
          'http://ip-api.com/batch',
          body: ips_to_look_up_in_api.map { |ip| {query: ip} }.to_json,
        ).parsed_response
      rescue Net::OpenTimeout, Errno::ECONNRESET => e # log connection issues as info, not error
        Rails.logger.info("Error fetching IP data, error=#{e.inspect}")
        Rollbar.info(e)
        []
      end

    api_response_ip_infos.each do |api_response_ip_info|
      ip, isp, city, state, country =
        api_response_ip_info.values_at(*%w[query isp city region countryCode])

      ip_info = {
        location: [city, state, country].reject(&:blank?).join(', '),
        isp: isp,
      }

      info[ip] = ip_info
      Rails.cache.write(cache_key(ip), ip_info, expires_in: 1.month)
    end

    info
  end

  def cache_key(ip)
    "ip-info:#{ip}"
  end

  def ips_needing_info
    requests_needing_ip_info.pluck(:ip).uniq
  end

  def requests_needing_ip_info
    Request.where.not(ip: nil).where(location: nil, isp: nil).order(:id)
  end
end

namespace :requests do
  desc 'Fetch and store locations for requests that lack one'
  task fetch_locations: :environment do
    RequestIpLookup.new.write_location_info_for_requests
    puts('Done updating IP address locations')
  end
end
