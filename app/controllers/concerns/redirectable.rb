# frozen_string_literal: true

module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :store_redirect_location
  end

  private

  def store_redirect_location
    redirect_to = params['redirect_to']
    if redirect_to.present?
      session['redirect_to'] = redirect_to
    end
  end
end
