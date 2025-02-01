module Cuprite::CustomDrivers
  DOMAIN_RESTRICTED_CUPRITE = :domain_restricted_cuprite
  UNRESTRICTED_CUPRITE = :unrestricted_cuprite

  class << self
    def register_with_capybara
      register_driver(
        DOMAIN_RESTRICTED_CUPRITE,
        url_whitelist: %r{\Ahttp://localhost:#{Capybara.server_port}/},
      )

      register_driver(UNRESTRICTED_CUPRITE)
    end

    private

    def register_driver(driver_name, **custom_options)
      Capybara.register_driver(driver_name) do |app|
        Capybara::Cuprite::Driver.new(
          app,
          base_options.merge(custom_options),
        )
      end
    end

    def base_options
      timeout = SpecHelper.is_ci? ? 10 : 999_999

      {
        headless: !SpecHelper.use_headful_chrome?,
        timeout:,
        process_timeout: timeout,
        logger: Cuprite::BrowserLogger.new,
        window_size: [1200, 800],
      }
    end
  end
end
