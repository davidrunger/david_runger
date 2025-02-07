class SitemapCrawler
  prepend Memoization

  def initialize(sitemap_url)
    @sitemap_url = sitemap_url
  end

  memoize \
  def urls
    urls_from_sitemap_doc(nokogiri_sitemap_doc(@sitemap_url))
  end

  private

  def nokogiri_sitemap_doc(url)
    Nokogiri::XML(Faraday.get(url).body)
  end

  def urls_from_sitemap_doc(sitemap)
    # Extract URLs from <url> tags
    urls = sitemap.xpath('//*:url/*:loc').map(&:text)

    # Extract nested sitemaps from <sitemap> tags
    sitemap.xpath('//*:sitemap/*:loc').each do |loc|
      nested_sitemap_url = loc.text
      nested_sitemap = nokogiri_sitemap_doc(nested_sitemap_url)
      urls.concat(urls_from_sitemap_doc(nested_sitemap))
    end

    urls.uniq.sort
  end
end
