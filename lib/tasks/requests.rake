namespace :requests do
  max_locations_to_fetch = 10 # the API we are using limits us to 150 req/min; we'll just do 10

  desc 'Fetch and store locations for requests that lack one'
  task fetch_locations: :environment do
    num_updated_requests = 0
    requests = Request.
      where(location: nil).
      where.not(ip: nil).
      ordered.
      limit(max_locations_to_fetch)
    puts "About to update #{requests.size} requests with location information."

    requests.find_each do |request|
      ip_address = request.ip

      location_data = HTTParty.get("http://ip-api.com/json/#{ip_address}").parsed_response
      city, country_code = location_data&.values_at('city', 'countryCode')
      if city.blank? && country_code.blank?
        puts "Failed to fetch a location for ip #{ip_address}, data=#{location_data.to_json}"
        next
      end

      location = "#{city}, #{country_code}"
      request.update!(location: location)
      num_updated_requests += 1
      puts "Updated Request #{request.id} (ip #{ip_address}) with location #{location}"
    end

    puts "Done. Updated #{num_updated_requests}."
  end
end

Rake::Task['assets:precompile'].enhance(%w[
  assets:clean_yarn_cache
  assets:rmrf_node_module
])
