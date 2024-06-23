# frozen_string_literal: true

class BrowserSupportChecker
  def initialize(browser)
    @browser = browser
  end

  def supported?
    !unsupported?
  end

  private

  def unsupported?
    @browser.ie?
  end
end
