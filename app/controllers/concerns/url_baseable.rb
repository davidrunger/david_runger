module UrlBaseable
  extend ActiveSupport::Concern

  included do
    helper_method :url_base
  end

  private

  def url_base
    @url_base ||=
      "#{request.scheme}://#{request.host}:#{request.port}".
        gsub(/:(80|443)\z/, '')
  end
end
