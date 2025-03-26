module PrerenderUtils
  class << self
    def cache_key(git_rev:, filename:)
      "prerendered-pages:#{git_rev}:#{filename}"
    end

    def transformed_s3_content(git_rev:, filename:)
      Aws::S3::Resource.new(region: 'us-east-1').
        bucket('david-runger-uploads').
        object("prerenders/#{git_rev}/#{filename}").
        get.body.read.
        then { html_with_absolutized_asset_paths(it) }
    rescue Aws::S3::Errors::NoSuchKey => error
      log_warning(error)

      nil
    rescue => error
      case Rails.env
      when 'production' then Rails.error.report(error, severity: :error, context: { filename: })
      when 'test' then raise(error)
      else log_warning(error)
      end

      nil
    end

    private

    def html_with_absolutized_asset_paths(html)
      if Rails.env.development?
        # convert relative asset paths to absolute paths pointing to davidrunger.com
        html.gsub!(%r{(href|src)="/vite/assets/}, %(\\1="#{DavidRunger::CANONICAL_URL}vite/assets/))
      end

      html
    end

    def log_warning(error)
      Rails.logger.warn("Could not fetch prerendered content: #{error.inspect}")
    end
  end
end
