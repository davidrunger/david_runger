# frozen_string_literal: true

Rails.configuration.middleware.use(Browser::Middleware) do
  if !BrowserSupportChecker.new(browser).supported?
    http_method = request.env['REQUEST_METHOD']
    requested_path = request.env['PATH_INFO']
    redirect_path = upgrade_browser_path

    Rails.logger.info(<<~LOG.squish)
      Redirecting request for #{http_method} #{requested_path}
      to #{redirect_path}
      because browser is not supported.
      user_agent='#{request.env['HTTP_USER_AGENT']}'
      browser.name='#{browser.name}'
      browser.version='#{browser.version}'
    LOG

    redirect_to(redirect_path)
  end
end
