# frozen_string_literal: true

class CheckHomeLinks::Launcher
  extend Memoist
  prepend ApplicationWorker

  def perform
    launch_with_spacing(
      worker_name: CheckHomeLinks::Checker.name,
      arguments_list: linked_urls,
      spacing_seconds: Rails.env.development? ? 1 : 10,
    )
  end

  private

  memoize \
  def linked_urls
    links.filter_map do |link|
      href = link.attr('href')
      href if href.match?(%r{\A(https?:)?//})
    end.uniq
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
    Faraday.get(DavidRunger::CANONICAL_URL).body
  end
end
