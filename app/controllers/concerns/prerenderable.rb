# frozen_string_literal: true

module Prerenderable
  extend ActiveSupport::Concern

  def serve_prerender_with_fallback(filename:, expected_content:, &fallback)
    prerendered_html = prerendered_html(filename)
    if prerendered_html
      if prerendered_html.include?(expected_content)
        # rubocop:disable Rails/OutputSafety
        render(
          layout: false,
          html:
            prerendered_html.
              then { html_with_nonced_scripts(_1) }.
              html_safe,
        )
        # rubocop:enable Rails/OutputSafety
      else
        Rails.logger.info(<<~LOG)
          A "#{filename}" prerender was found, but it did not include "#{expected_content}".
        LOG
        instance_eval(&fallback)
      end
    else
      Rails.logger.info(%(Could not find a "#{filename}" prerender.))
      instance_eval(&fallback)
    end
  end

  private

  def prerendered_html(filename)
    return nil if Flipper.enabled?(:disable_prerendering)

    git_rev = ENV.fetch('GIT_REV')

    Rails.cache.fetch(
      "prerendered-pages:#{git_rev}:#{filename}",
      expires_in: 1.day,
      skip_nil: true,
    ) do
      Aws::S3::Resource.new(region: 'us-east-1').
        bucket('david-runger-uploads').
        object("prerenders/#{git_rev}/#{filename}").
        get.body.read.
        then { html_with_absolutized_asset_paths(_1) }
    rescue Aws::S3::Errors::NoSuchKey => error
      log_warning(error)
      nil
    rescue => error
      case Rails.env
      when 'production' then Rollbar.error(error, filename:)
      when 'test' then raise(error)
      else log_warning(error)
      end
      nil
    end
  end

  def html_with_absolutized_asset_paths(html)
    if Rails.env.development?
      # convert relative asset paths to absolute paths pointing to davidrunger.com
      html.gsub!(%r{(href|src)="/vite/assets/}, %(\\1="#{DavidRunger::CANONICAL_URL}vite/assets/))
    end

    html
  end

  def html_with_nonced_scripts(html)
    html.gsub!(/<script +nonce="" *>/, %(<script nonce="#{content_security_policy_nonce}">))
    html
  end

  def log_warning(error)
    Rails.logger.warn("Could not fetch prerendered content: #{error.inspect}")
  end
end
