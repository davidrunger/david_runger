module Cuprite::DomainRestrictedDriver
  class << self
    def register_driver_with_capybara
      Capybara.register_driver(:domain_restricted_cuprite) do |app|
        timeout = SpecHelper.is_ci? ? 10 : 999_999

        Capybara::Cuprite::Driver.new(
          app,
          headless: !SpecHelper.use_headful_chrome?,
          timeout:,
          process_timeout: timeout,
          logger: Cuprite::BrowserLogger.new,
          window_size: [1200, 800],
          url_whitelist: %r{\Ahttp://localhost:#{Capybara.server_port}/},
        )
      end
    end
  end
end
