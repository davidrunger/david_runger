class LogSelectorKeyboardShortcut
  def initialize(browser)
    @browser = browser
  end

  def shortcut
    if @browser.platform.mac?
      'Cmd+K'
    else
      'Ctrl+K'
    end
  end
end
