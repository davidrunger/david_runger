class BrowserSupportChecker
  def initialize(browser)
    @browser = browser
  end

  def supported?
    !unsupported?
  end

  private

  def first_temporary_uncovered_method
    true
  end

  def second_temporary_uncovered_method
    true
  end

  def unsupported?
    @browser.ie?
  end
end
