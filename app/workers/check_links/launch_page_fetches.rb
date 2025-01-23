class CheckLinks::LaunchPageFetches
  prepend ApplicationWorker

  SITEMAP_URL = 'https://davidrunger.com/sitemap.xml'

  def perform
    launch_with_spacing(
      worker: CheckLinks::LaunchLinkChecksForPage,
      arguments_list: sitemap_urls.map { [it] },
      spacing_seconds: Rails.env.development? ? 10.seconds : 5.minutes,
    )
  end

  private

  def sitemap_urls
    SitemapCrawler.new(SITEMAP_URL).urls
  end
end
