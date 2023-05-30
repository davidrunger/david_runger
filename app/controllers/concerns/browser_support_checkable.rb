# frozen_string_literal: true

module BrowserSupportCheckable
  extend ActiveSupport::Concern
  prepend MemoWise

  included do
    helper_method :browser_support_checker
  end

  private

  memo_wise \
  def browser_support_checker
    BrowserSupportChecker.new(browser)
  end
end
