class HomeController < ApplicationController
  include Prerenderable

  skip_before_action :authenticate_user!, only: %i[index upgrade_browser]
  render_flash_messages_via_js(only: %i[index])

  def index
    skip_authorization

    @description = 'The personal website of web developer David Runger'
    @ios_theme_color = '#0a0a0a'

    serve_prerender_with_fallback(
      filename: 'home.html',
      expected_content: 'Full stack web developer',
    ) do
      render :index
    end
  end

  def upgrade_browser
    skip_authorization
    if browser_support_checker.supported?
      redirect_to(root_path)
    else
      render :upgrade_browser
    end
  end
end
