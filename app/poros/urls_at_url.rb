class UrlsAtUrl
  prepend Memoization

  def initialize(page_url)
    @page_url = page_url
  end

  memoize \
  def urls
    links.filter_map do |link|
      href = link.attr('href')
      href if url?(href)
    end.uniq.sort
  end

  private

  def url?(href)
    href&.match?(%r{\A(https?:)?//})
  end

  memoize \
  def links
    nokogiri_document.css('a')
  end

  memoize \
  def nokogiri_document
    Nokogiri::HTML(page_content)
  end

  memoize \
  def page_content
    Faraday.get(@page_url).body
  end
end
