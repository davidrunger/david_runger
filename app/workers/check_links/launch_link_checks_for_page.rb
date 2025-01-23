class CheckLinks::LaunchLinkChecksForPage
  prepend ApplicationWorker

  def perform(url)
    @page_url = url

    if Faraday.head(url).headers['content-type'].include?('text/html')
      launch_with_spacing(
        worker: CheckLinks::Checker,
        arguments_list:,
        spacing_seconds: Rails.env.development? ? 1 : 10,
      )
    else
      logger.info("Not checking links for '#{url}' because it's not an HTML page.")
    end
  end

  private

  def arguments_list
    UrlsAtUrl.new(@page_url).urls.map do |url|
      [url, @page_url]
    end
  end
end
