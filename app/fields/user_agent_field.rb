# frozen_string_literal: true

require 'administrate/field/base'

class UserAgentField < Administrate::Field::Base
  extend Memoist

  def raw_user_agent
    data
  end

  def summary_info
    if good_browser_data?
      "#{browser_name} #{browser_version} on #{browser_platform}"
    else
      data
    end
  end

  private

  def good_browser_data?
    [browser_name, browser_version, browser_platform].all?(&:present?) &&
      browser_name != 'Unknown Browser'
  end

  memoize \
  def browser
    Browser.new(data)
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
