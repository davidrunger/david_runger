# frozen_string_literal: true

if Rails.env.test?
  class Selenium::WebDriver::Chromium::Driver < Selenium::WebDriver::Driver
    protected

    def devtools_version
      Rails.logger.info(<<~LOG.squish)
        Using monkeypateched Selenium::WebDriver::Chromium::Driver#devtools_version.
      LOG
      version = Integer(capabilities.browser_version.split('.').first)
      begin
        require "selenium/devtools/v#{@version}"
        # :nocov:
      rescue LoadError
        previous_version = version - 1
        puts(<<~LOG.squish)
          LoadError occurred trying to load selenium-devtools #{version}, falling back to
          #{previous_version}.
        LOG
        previous_version
      else
        version
        # :nocov:
      end
    end
  end
end
