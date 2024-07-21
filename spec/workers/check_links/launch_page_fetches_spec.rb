RSpec.describe CheckLinks::LaunchPageFetches do
  subject(:launch_page_fetches) { CheckLinks::LaunchPageFetches.new }

  describe '#perform' do
    subject(:perform) { launch_page_fetches.perform }

    context 'when sitemaps are returned by davidrunger.com' do
      before do
        stub_request(:get, 'https://davidrunger.com/sitemap.xml').
          to_return(status: 200, body: <<~XML, headers: {})
            <?xml version="1.0" encoding="UTF-8"?>
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <sitemap>
                <loc>https://davidrunger.com/root-sitemap.xml</loc>
              </sitemap>
              <sitemap>
                <loc>https://davidrunger.com/blog/sitemap.xml</loc>
              </sitemap>
            </sitemapindex>
          XML

        stub_request(:get, 'https://davidrunger.com/root-sitemap.xml').
          to_return(status: 200, body: <<~XML, headers: {})
            <?xml version="1.0" encoding="UTF-8"?>
            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
              <url>
                <loc>https://davidrunger.com/</loc>
                <priority>1.0</priority>
              </url>
              <url>
                <loc>https://davidrunger.com/David-Runger-Resume.pdf</loc>
                <priority>0.8</priority>
              </url>
            </urlset>
          XML

        stub_request(:get, 'https://davidrunger.com/blog/sitemap.xml').
          to_return(status: 200, body: <<~XML, headers: {})
            <?xml version="1.0" encoding="UTF-8"?>
            <urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <url>
                <loc>https://davidrunger.com/blog/using-vs-code-as-a-rails-app-update-merge-tool</loc>
                <lastmod>2024-06-26T22:23:17-05:00</lastmod>
              </url>
              <url>
                <loc>https://davidrunger.com/blog/</loc>
                <lastmod>2024-06-26T22:55:12-05:00</lastmod>
              </url>
            </urlset>
          XML
      end

      it 'enqueues one CheckLinks::LaunchLinkChecksForPage job per URL in the sitemap' do
        perform

        expected_page_urls_to_check =
          %w[
            https://davidrunger.com/
            https://davidrunger.com/David-Runger-Resume.pdf
            https://davidrunger.com/blog/using-vs-code-as-a-rails-app-update-merge-tool
            https://davidrunger.com/blog/
          ]

        expected_page_urls_to_check.each do |url|
          expect(CheckLinks::LaunchLinkChecksForPage).
            to have_enqueued_sidekiq_job.
            with(url)
        end

        expect(CheckLinks::LaunchLinkChecksForPage).
          to have_enqueued_sidekiq_job.
          exactly(expected_page_urls_to_check.size).
          times
      end
    end
  end
end
