# frozen_string_literal: true

module Prerenderable
  extend ActiveSupport::Concern

  def serve_prerender_with_fallback(filename:, &fallback)
    prerendered_html = prerendered_html(filename)
    if prerendered_html
      # rubocop:disable Rails/OutputSafety
      render html: html_with_webp_class_if_chrome(prerendered_html).html_safe, layout: false
      # rubocop:enable Rails/OutputSafety
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
        yield_self { html_with_absolutized_asset_paths(_1) }
    rescue Aws::S3::Errors::NoSuchKey => error
      log_warning(error)
      nil
    rescue => error
      case Rails.env
      when 'production' then Rollbar.error(error, filename: filename)
      when 'test' then raise(error)
      else log_warning(error)
      end
      nil
    end
  end

  def html_with_absolutized_asset_paths(html)
    if Rails.env.development?
      # convert relative asset paths to absolute paths pointing to davidrunger.com
      html.gsub!(%r{(href|src)="/packs/}, '\1="https://davidrunger.com/packs/')
    end

    html
  end

  def html_with_webp_class_if_chrome(html)
    if browser.chrome?
      html.sub!('<html>', '<html class="webp">')
    end

    html
  end

  def log_warning(error)
    Rails.logger.warn("Could not fetch prerendered content: #{error.inspect}")
  end
end
