# frozen_string_literal: true

class BlogController < ApplicationController
  include ReverseProxy::Controller

  REQUEST_HEADER_KEYS_TO_FORWARD = %w[
    accept
    accept-language
  ].freeze
  REQUEST_HEADERS_TO_ADD = {
    'accept-encoding' => 'gzip',
    'connection' => 'keep-alive',
  }.freeze

  skip_before_action :authenticate_user!, only: %i[assets index show]

  def index
    skip_authorization
    reverse_proxy(*proxy_arguments)
  end

  def show
    skip_authorization
    reverse_proxy(*proxy_arguments)
  end

  def assets
    skip_authorization
    reverse_proxy(*proxy_arguments)
  end

  private

  def proxy_arguments
    [ENV.fetch('BLOG_ROOT_URL'), { headers: proxy_request_headers }]
  end

  def proxy_request_headers
    nilled_headers.
      merge(request_headers_to_forward).
      merge(REQUEST_HEADERS_TO_ADD)
  end

  def request_headers_to_forward
    http_headers.select { |key, _value| key.in?(REQUEST_HEADER_KEYS_TO_FORWARD) }.to_h
  end

  def nilled_headers
    http_headers.keys.to_h { [_1, nil] }
  end

  def http_headers
    # https://stackoverflow.com/a/32405432/4009384
    request.headers.env.filter_map do |key, value|
      if key.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || key.start_with?('HTTP_')
        [key.delete_prefix('HTTP_').tr('_', '-').downcase, value]
      end
    end.sort.to_h
  end
end
