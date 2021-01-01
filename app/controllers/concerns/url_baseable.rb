# frozen_string_literal: true

module UrlBaseable
  extend ActiveSupport::Concern

  included do
    helper_method :url_base
  end

  private

  def url_base
    @url_base ||=
      case Rails.env
      when 'development' then "http://#{request.host}:#{request.port}"
      else "https://#{request.host}"
      end
  end
end
