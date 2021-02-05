# frozen_string_literal: true

RSpec.describe 'Home page', :prerendering_disabled do
  it 'says "David Runger / Full stack web developer"' do
    visit root_path

    expect(page).to have_text(<<~HEADLINE)
      David Runger
      Full stack web developer
    HEADLINE

    Percy.snapshot(page, { name: 'Homepage' })
  end

  # we need to use the :rack_test driver because Chrome doesn't have the page.driver.header method
  context 'when there is an `X-Request-Start` HTTP header', :rack_test_driver do
    before { page.driver.header('X-Request-Start', (Time.current.to_f * 1_000.0).round.to_s) }

    context 'when there is a `User-Agent` header' do
      before { page.driver.header('User-Agent', user_agent) }

      let(:user_agent) { 'Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)' }

      context 'when Sidekiq jobs are executed' do
        around { |spec| Sidekiq::Testing.inline! { spec.run } }

        let!(:ip_info_request_stub) do
          stub_request(:get, 'http://ip-api.com/json/127.0.0.1').
            to_return(
              status: 200,
              body: {
                'status' => 'success',
                'country' => 'United States',
                'countryCode' => 'US',
                'region' => 'CA',
                'regionName' => 'California',
                'city' => 'San Diego',
                'zip' => '92123',
                'lat' => 32.7967,
                'lon' => -117.1367,
                'timezone' => 'America/Los_Angeles',
                'isp' => 'Spectrum',
                'org' => 'Charter Communications',
                'as' => 'AS20001 Charter Communications Inc',
                'query' => '76.167.213.95', # rubocop:disable Style/IpAddresses
              }.to_json,
              headers: { 'content-type' => 'application/json; charset=utf-8' },
            )
        end

        it 'creates a `Request` with a `total` time' do
          spec_start_time = Time.current

          expect {
            visit root_path
          }.to change {
            Request.where('requests.requested_at > ?', spec_start_time).map(&:attributes)
          }.from([]).to([
            {
              'id' => Integer,
              'admin_user_id' => nil,
              'user_id' => nil,
              'auth_token_id' => nil,
              'url' => 'http://www.example.com/',
              'handler' => 'home#index',
              'referer' => nil,
              'params' => {},
              'method' => 'GET',
              'format' => 'html',
              'status' => 200,
              'view' => Integer,
              'db' => Integer,
              'total' => Integer,
              'ip' => '127.0.0.1', # rubocop:disable Style/IpAddresses
              'user_agent' => user_agent,
              'requested_at' => Time,
              'location' => 'San Diego, CA, US',
              'isp' => 'Spectrum',
              'request_id' => String,
            },
          ])

          expect(ip_info_request_stub).to have_been_requested
        end
      end
    end
  end

  # we need to use the :rack_test driver because Chrome doesn't have the page.driver.header method
  context 'when using an unsupported browser', :rack_test_driver do
    let(:ie_11_user_agent) { 'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko' }

    before do
      page.driver.header('User-Agent', ie_11_user_agent)

      browser = Browser.new(ie_11_user_agent)
      expect(browser.name).to eq('Internet Explorer')
      expect(browser.version).to eq('11')
      expect(BrowserSupportChecker.new(browser)).not_to be_supported
    end

    context 'when an Accept header of */* is provided' do
      before { page.driver.header('Accept', '*/*') }

      it 'redirects to upgrade_browser_path' do
        visit root_path

        expect(page).to have_current_path(upgrade_browser_path)
        expect(page).to have_text("We don't support Internet Explorer version 11.")
      end
    end
  end
end
