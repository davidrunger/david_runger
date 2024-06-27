# frozen_string_literal: true

class UrlsAtUrl
  prepend MemoWise

  def initialize(page_url)
    @page_url = page_url
  end

  memo_wise \
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

  memo_wise \
  def links
    nokogiri_document.css('a')
  end

  memo_wise \
  def nokogiri_document
    Nokogiri::HTML(page_content)
  end

  memo_wise \
  def page_content
    Faraday.get(@page_url).body
  end
end
