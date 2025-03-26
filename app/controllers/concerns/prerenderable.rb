module Prerenderable
  extend ActiveSupport::Concern

  def serve_prerender_with_fallback(filename:, expected_content:, &fallback)
    if params.key?('prerender')
      Rails.logger.info('Skipping prerendered content because a prerender param is present.')
      instance_eval(&fallback)
    elsif (prerendered_html = prerendered_html(filename))
      if prerendered_html.include?(expected_content)
        # rubocop:disable Rails/OutputSafety
        render(
          layout: false,
          html:
            prerendered_html.
              then { html_with_nonced_scripts(it) }.
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
      PrerenderUtils.cache_key(git_rev:, filename:),
      expires_in: 1.day,
      skip_nil: true,
    ) do
      PrerenderUtils.transformed_s3_content(git_rev:, filename:)
    end ||
      Rails.cache.read(
        PrerenderUtils.cache_key(git_rev: 'deploy-fallback', filename:),
      )
  end

  def html_with_nonced_scripts(html)
    html.gsub!(/<script +nonce="" *>/, %(<script nonce="#{content_security_policy_nonce}">))
    html
  end
end
