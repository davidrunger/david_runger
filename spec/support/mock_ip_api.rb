module MockIpApi
  class << self
    def stub_request(ip_address, city: nil, country: nil, isp: nil, state: nil)
      WebMock.stub_request(:get, "http://ip-api.com/json/#{ip_address}").
        to_return(
          status: 200,
          body: {
            'status' => 'success',
            'country' => Faker::Address.country,
            'countryCode' => country || Faker::Address.country_code,
            'region' => state || Faker::Address.state_abbr,
            'regionName' => Faker::Address.state,
            'city' => city || Faker::Address.city,
            'zip' => Faker::Address.zip.first(5),
            'lat' => Faker::Address.latitude,
            'lon' => Faker::Address.longitude,
            'timezone' => Faker::Address.time_zone,
            'isp' => isp || Faker::Company.name,
            'org' => Faker::Company.name,
            'as' => "AS#{rand(100_000)} #{Faker::Company.name}",
            'query' => ip_address,
          }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )
    end
  end
end
