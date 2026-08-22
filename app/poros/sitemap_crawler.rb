class SitemapCrawler
  prepend Memoization

  MAX_SITEMAP_DEPTH = 5
  MAX_SITEMAPS = 100

  def initialize(sitemap_url)
    @sitemap_url = sitemap_url
  end

  memoize \
  def urls
    urls_from_sitemap_url(@sitemap_url, visited_sitemap_urls: Set.new, depth: 0).uniq.sort
  end

  private

  def urls_from_sitemap_url(url, visited_sitemap_urls:, depth:)
    normalized_url = normalized_sitemap_url(url)
    if normalized_url &&
        visited_sitemap_urls.exclude?(normalized_url) &&
        depth <= MAX_SITEMAP_DEPTH &&
        visited_sitemap_urls.size < MAX_SITEMAPS
      visited_sitemap_urls.add(normalized_url)
      urls_from_sitemap_doc(
        nokogiri_sitemap_doc(normalized_url),
        visited_sitemap_urls:,
        depth:,
      )
    else
      []
    end
  end

  def nokogiri_sitemap_doc(url)
    Nokogiri::XML(Faraday.get(url).body)
  end

  def urls_from_sitemap_doc(sitemap, visited_sitemap_urls:, depth:)
    # Extract URLs from <url> tags
    urls = sitemap.xpath('//*:url/*:loc').filter_map { normalized_page_url(it.text) }

    # Extract nested sitemaps from <sitemap> tags
    sitemap.xpath('//*:sitemap/*:loc').each do |loc|
      urls.concat(
        urls_from_sitemap_url(
          loc.text,
          visited_sitemap_urls:,
          depth: depth + 1,
        ),
      )
    end

    urls
  end

  def normalized_sitemap_url(url)
    if site_url?(url)
      normalized_url(url)
    end
  end

  def normalized_page_url(url)
    if site_url?(url)
      normalized_url(url)
    end
  end

  def site_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTPS) && uri.host == DavidRunger::CANONICAL_DOMAIN
  rescue URI::InvalidURIError
    false
  end

  def normalized_url(url)
    URI.parse(url).normalize.to_s
  end
end
