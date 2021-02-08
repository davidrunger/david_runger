# frozen_string_literal: true

class HomeController < ApplicationController
  include Prerenderable

  skip_before_action :authenticate_user!, only: %i[index upgrade_browser]

  def index
    skip_authorization
    @description = 'The personal website of web developer David Runger'
    serve_prerender_with_fallback(
      filename: 'home.html',
      expected_content: 'Full stack web developer',
    ) do
      render :index
    end
  end

  def upgrade_browser
    skip_authorization
    if BrowserSupportChecker.new(browser).supported?
      redirect_to(root_path)
    else
      render :upgrade_browser
    end
  end
end
