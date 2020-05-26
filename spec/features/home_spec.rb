# frozen_string_literal: true

RSpec.describe 'Home page' do
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
          'query' => '76.167.213.95',
        }.to_json,
        headers: { 'content-type' => 'application/json; charset=utf-8' },
      )
  end

  it 'says "David Runger / Full stack web developer", creates `Request`, fetches IP info', :js do
    spec_start_time = Time.current

    expect {
      Sidekiq::Testing.inline! do
        visit root_path
      end
    }.to change {
      Request.where('requests.requested_at > ?', spec_start_time).map(&:attributes)
    }.from([]).to([
      {
        'id' => Integer,
        'user_id' => nil,
        'url' => %r{http://127.0.0.1:\d+/},
        'handler' => 'home#index',
        'referer' => nil,
        'params' => {},
        'method' => 'GET',
        'format' => 'html',
        'status' => 200,
        'view' => Integer,
        'db' => Integer,
        'ip' => '127.0.0.1',
        'user_agent' => /HeadlessChrome/,
        'requested_at' => Time,
        'location' => 'San Diego, CA, US',
        'isp' => 'Spectrum',
        'request_id' => String,
      },
    ])

    expect(page).to have_text(<<~HEADLINE)
      David Runger
      Full stack web developer
    HEADLINE

    Percy.snapshot(page, { name: 'Homepage' })

    expect(ip_info_request_stub).to have_been_requested
  end

  context 'when using an unsupported browser' do
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
