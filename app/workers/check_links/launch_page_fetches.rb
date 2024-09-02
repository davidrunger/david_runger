class CheckLinks::LaunchPageFetches
  prepend ApplicationWorker

  SITEMAP_URL = 'https://davidrunger.com/sitemap.xml'

  def perform
    sitemap_urls.each do |url|
      CheckLinks::LaunchLinkChecksForPage.perform_async(url)
    end
  end

  private

  def sitemap_urls
    SitemapCrawler.new(SITEMAP_URL).urls
  end
end
