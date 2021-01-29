# frozen_string_literal: true

module Prerenderable
  extend ActiveSupport::Concern

  def serve_prerender_with_fallback(filename:, &fallback)
    prerendered_html = prerendered_html(filename)
    if prerendered_html
      render html: prerendered_html.html_safe, layout: false # rubocop:disable Rails/OutputSafety
    else
      instance_eval(&fallback)
    end
  end

  private

  def prerendered_html(filename)
    return nil if Flipper.enabled?(:disable_prerendering)

    Rails.cache.fetch(
      "prerendered-pages:#{filename}",
      expires_in: 1.day,
      skip_nil: true,
    ) do
      Aws::S3::Resource.new(region: ENV['S3_REGION']).
        bucket(ENV['S3_BUCKET']).
        object("prerenders/#{filename}").
        get.body.read.
        yield_self do |html|
          case Rails.env
          when 'development'
            # convert relative asset paths to absolute paths pointing to davidrunger.com
            html.gsub(%r{(href|src)="/packs/}, '\1="https://davidrunger.com/packs/')
          else html
          end
        end
    rescue => error
      case Rails.env
      when 'production' then Rollbar.error(error, filename: filename)
      when 'test' then raise(error)
      else Rails.logger.warn("Could not fetch prerendered content: #{error.inspect}")
      end
      nil
    end
  end
end
