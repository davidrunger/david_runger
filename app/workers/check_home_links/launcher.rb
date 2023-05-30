# frozen_string_literal: true

class CheckHomeLinks::Launcher
  prepend MemoWise
  prepend ApplicationWorker

  def perform
    launch_with_spacing(
      worker_name: CheckHomeLinks::Checker.name,
      arguments_list: linked_urls,
      spacing_seconds: Rails.env.development? ? 1 : 10,
    )
  end

  private

  memo_wise \
  def linked_urls
    links.filter_map do |link|
      href = link.attr('href')
      href if url?(href)
    end.uniq
  end

  def url?(href)
    href.match?(%r{\A(https?:)?//})
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
    Faraday.get(DavidRunger::CANONICAL_URL).body
  end
end
