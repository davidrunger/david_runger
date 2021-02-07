# frozen_string_literal: true

class RequestDecorator < Draper::Decorator
  extend Memoist

  delegate_all

  def pretty_user_agent
    if good_browser_data?
      "#{browser_name} #{browser_version} on #{browser_platform}"
    else
      user_agent
    end
  end

  def to_s
    "Request #{id} for #{handler}"
  end

  private

  def good_browser_data?
    [browser_name, browser_version, browser_platform].all?(&:present?) &&
      browser_name != 'Unknown Browser'
  end

  memoize \
  def browser
    Browser.new(user_agent)
  end

  def browser_name
    browser.name
  end

  def browser_version
    browser.version
  end

  def browser_platform
    browser.platform.name
  end
end
