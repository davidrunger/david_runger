# frozen_string_literal: true

module UrlBaseable
  extend ActiveSupport::Concern

  included do
    helper_method :url_base
  end

  private

  def url_base
    host = request.host

    @url_base ||=
      case Rails.env
      when 'development' then "http://#{host}:#{request.port}"
      else "https://#{host}"
      end
  end
end
