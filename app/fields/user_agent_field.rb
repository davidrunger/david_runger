# frozen_string_literal: true

require 'administrate/field/base'

class UserAgentField < Administrate::Field::Base
  def raw_user_agent
    data
  end

  def summary_info
    browser_name = browser.name
    browser_version = browser.version
    browser_platform = browser.platform.name
    if [browser_name, browser_version, browser_platform].all?(&:present?)
      "#{browser_name} #{browser_version} on #{browser_platform}"
    else
      data
    end
  end

  private

  def browser
    Browser.new(data)
  end
end
