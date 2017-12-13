namespace :requests do
  # the API we are using limits us to 100 IPs per request (and 150 req/min)
  MAX_LOCATIONS_TO_FETCH = 100

  desc 'Fetch and store locations for requests that lack one'
  task fetch_locations: :environment do
    ip_addresses_to_lookup =
      Request.
        select('DISTINCT ON (ip) ip').
        where(location: nil).
        where.not(ip: nil).
        limit(MAX_LOCATIONS_TO_FETCH).
        map(&:ip) # map rather than pluck so as not to override the DISTINCT ON select

    next if ip_addresses_to_lookup.blank?

    puts "About to lookup location data for #{ip_addresses_to_lookup.size} IP addresses"
    begin
      location_data = HTTParty.post(
        'http://ip-api.com/batch',
        body: ip_addresses_to_lookup.map { |ip| {query: ip} }.to_json,
      ).parsed_response
    rescue Net::OpenTimeout, Errno::ECONNRESET => e # log connection issues as info, not error
      Rollbar.info(e)
    end

    next if location_data.blank?

    ip_address_locations = Hash[location_data.map do |location_datum|
      ip_address, city, state, country =
        location_datum.values_at(*%w[query city region countryCode])
      [ip_address, "#{city}, #{state}, #{country}"]
    end]

    ip_address_locations.each do |ip_address, location|
      Request.where(ip: ip_address, location: nil).each do |request|
        request.update!(location: location)
        puts "Updated Request #{request.id} to have location #{location}"
      end
    end

    puts 'Done updating IP address locations'
  end
end
