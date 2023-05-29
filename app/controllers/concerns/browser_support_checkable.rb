# frozen_string_literal: true

module BrowserSupportCheckable
  extend ActiveSupport::Concern
  include Memery

  included do
    helper_method :browser_support_checker
  end

  private

  memoize \
  def browser_support_checker
    BrowserSupportChecker.new(browser)
  end
end
