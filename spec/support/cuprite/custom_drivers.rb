module Cuprite::CustomDrivers
  DOMAIN_RESTRICTED_CUPRITE = :domain_restricted_cuprite
  UNRESTRICTED_CUPRITE = :unrestricted_cuprite

  class << self
    def register_with_capybara
      register_driver(
        DOMAIN_RESTRICTED_CUPRITE,
        -> { { url_whitelist: %r{\Ahttp://localhost:#{Capybara.server_port}/} } },
      )

      register_driver(UNRESTRICTED_CUPRITE)
    end

    private

    def register_driver(driver_name, custom_options_proc = nil)
      Capybara.register_driver(driver_name) do |app|
        Capybara::Cuprite::Driver.new(
          app,
          base_options.merge(custom_options_proc&.call || {}),
        )
      end
    end

    def base_options
      timeout = SpecHelper.is_ci? ? 10 : 999_999

      {
        headless: !SpecHelper.use_headful_chrome?,
        timeout:,
        process_timeout: 30,
        logger: Cuprite::BrowserLogger.new,
        window_size: [1200, 800],
        browser_options: {
          # Most of these are lifted from:
          # https://github.com/AlexBeznoss/beagle/blob/ef29de15f74d4076ea41293e3b8703e568e42125/test/support/chromedriver.rb#L26
          # Available flags (there are a ton) are listed here: https://peter.sh/experiments/chromium-command-line-switches/
          'disable-background-timer-throttling' => nil,
          'disable-breakpad' => nil,
          'disable-client-side-phishing-detection' => nil,
          'disable-default-apps' => nil,
          'disable-extensions': nil,
          'disable-features' => 'site-per-process,TranslateUI',
          'disable-gpu': nil,
          'disable-hang-monitor' => nil,
          'disable-ipc-flooding-protection' => nil,
          'disable-popup-blocking' => nil,
          'disable-prompt-on-repost' => nil,
          'disable-session-crashed-bubble' => nil,
          'disable-sync' => nil,
          'disable-translate' => nil,
          'keep-alive-for-test' => nil,
          'no-first-run' => nil,
          'no-sandbox': nil,
        },
      }
    end
  end
end
