RSpec.describe 'Home page', :prerendering_disabled do
  it 'says "David Runger / Full stack web developer"' do
    visit root_path

    expect(page).to have_text(<<~HEADLINE, normalize_ws: false)
      David Runger
      Full stack web developer
    HEADLINE

    page.percy_snapshot('Homepage')
  end

  # we need to use the :rack_test driver because Chrome doesn't have the page.driver.header method
  context 'when there is an `X-Request-Start` HTTP header', :rack_test_driver do
    before { page.driver.header('X-Request-Start', Time.current.to_f.round(3).to_s) }

    context 'when there is a `User-Agent` header' do
      before { page.driver.header('User-Agent', user_agent) }

      let(:user_agent) { 'Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)' }

      context 'when Sidekiq jobs are executed', :inline_sidekiq do
        let!(:ip_info_request_stub) do
          MockIpApi.stub_request(
            ip_address,
            city: 'San Diego',
            country: 'US',
            isp: 'Spectrum',
            state: 'CA',
          )
        end

        context 'when the request has a non-localhost IP address' do
          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(ActionDispatch::Request).
              to receive(:remote_ip).
              and_return(ip_address)
            # rubocop:enable RSpec/AnyInstance
          end

          let(:ip_address) { Faker::Internet.ip_v4_address }

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
                'url' => 'http://localhost:3001/',
                'handler' => 'home#index',
                'referer' => nil,
                'params' => {},
                'method' => 'GET',
                'format' => 'html',
                'status' => 200,
                'view' => Integer,
                'db' => Integer,
                'total' => Integer,
                'ip' => ip_address,
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
