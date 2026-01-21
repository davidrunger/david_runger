RSpec.describe 'Home page', :prerendering_disabled do
  it 'says "David Runger / Full stack web developer" and tracks scrolling and clicks on external links' do
    visit root_path

    expect(page).to have_text(<<~HEADLINE, normalize_ws: false)
      David Runger
      Full stack web developer
    HEADLINE

    # Iff using Percy, wait for skill SVGs to render, for consistent screenshots.
    if ENV.fetch('PERCY_TOKEN', nil).present?
      wait_for do
        # Check that every skill row SVG container has an SVG
        # and that every SVG has a positive width and height.
        page.evaluate_script(<<~JS)
          (document.querySelectorAll('.skills .svg-container').length ===
            document.querySelectorAll('.skills .svg-container svg').length) &&
            [...document.querySelectorAll('.skills .svg-container svg')].every(svg => {
              const bbox = svg.getBBox();
              return bbox.width > 0 && bbox.height > 0;
            })
        JS
      end.to eq(true)
    end

    page.percy_snapshot('Homepage')

    # Scroll tracking >>>
    event_count_before = Event.count

    page.scroll_to(:bottom)

    wait_for { Event.count }.to eq(event_count_before + 1)

    new_event = Event.reorder(:created_at).last!

    expect(new_event).to have_attributes(
      admin_user_id: nil,
      data: hash_including(
        'page_url' => "#{Capybara.app_host}/",
      ),
      ip: '127.0.0.1',
      'stack_trace' => [
        %r{
          /david_runger/app/controllers/api/events_controller\.rb:\d+:
          in\s'Api::EventsController#create'
        }x,
      ],
      type: 'scroll',
      user_id: nil,
    )

    page.scroll_to(:top)

    # Verify that we do _not_ add yet another scroll Event after scrolling back up.
    expect(Event.count).to eq(event_count_before + 1)
    # <<< Scroll tracking

    # External link click tracking >>>
    event_count_before = Event.count

    # Click the resume link twice, because the event tracking as the page
    # unloads is intrinsically flaky (not just in test, but also for real).
    # Clicking the link twice makes the chance of flaky failures much smaller
    # (and low enough that we might never see a flake again).
    click_on('View Resume (pdf)')
    page.driver.go_back
    click_on('View Resume (pdf)')

    wait_for { Event.count }.to be_between(event_count_before + 1, event_count_before + 2)

    new_event = Event.reorder(:created_at).last!

    expect(new_event).to have_attributes(
      admin_user_id: nil,
      data: hash_including(
        'href' => 'https://david-runger-public-uploads.s3.amazonaws.com/David-Runger-Resume.pdf',
        'page_url' => "#{Capybara.app_host}/",
        'text' => 'View Resume (pdf)',
      ),
      ip: '127.0.0.1',
      'stack_trace' => [
        %r{
          /david_runger/app/controllers/api/events_controller\.rb:\d+:
          in\s'Api::EventsController#create'
        }x,
      ],
      type: 'external_link_click',
      user_id: nil,
    )
    # <<< External link click tracking
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
                'url' => "http://localhost:#{Capybara.server_port}/",
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
