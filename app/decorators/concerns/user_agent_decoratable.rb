module UserAgentDecoratable
  prepend Memoization

  memoize \
  def pretty_user_agent
    user_agent_description(user_agent)
  end

  private

  def user_agent_description(user_agent)
    browser = Browser.new(user_agent)
    browser_name = browser.name
    browser_version = browser.version
    browser_platform = browser.platform.name

    if [browser_name, browser_version, browser_platform].all?(&:present?) &&
        browser_name != 'Unknown Browser'
      "#{browser_name} #{browser_version} on #{browser_platform}"
    else
      user_agent
    end
  rescue StandardError
    user_agent
  end
end
