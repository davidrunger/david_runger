# frozen_string_literal: true

class BrowserSupportChecker
  def initialize(browser)
    @browser = browser
  end

  def supported?
    !unsupported?
  end

  def supports_webp?
    # https://www.caniuse.com/webp
    # rubocop:disable Lint/NumberConversion
    (@browser.chrome? && (@browser.version.to_i >= 32)) ||
      (@browser.firefox? && (@browser.version.to_i >= 65))
    # rubocop:enable Lint/NumberConversion
  end

  private

  def unsupported?
    @browser.ie?
  end
end
