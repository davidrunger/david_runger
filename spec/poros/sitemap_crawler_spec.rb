RSpec.describe SitemapCrawler do
  describe '#urls' do
    subject(:urls) { SitemapCrawler.new(sitemap_url).urls }

    let(:sitemap_url) { 'https://davidrunger.com/sitemap.xml' }

    before do
      stub_request(:get, sitemap_url).to_return(
        body: <<~XML,
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://davidrunger.com/nested-sitemap.xml</loc>
            </sitemap>
            <sitemap>
              <loc>https://example.com/sitemap.xml</loc>
            </sitemap>
            <sitemap>
              <loc>not a URL</loc>
            </sitemap>
          </sitemapindex>
        XML
      )
      stub_request(:get, 'https://davidrunger.com/nested-sitemap.xml').to_return(
        body: <<~XML,
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>
              <loc>https://davidrunger.com/blog/</loc>
            </url>
            <url>
              <loc>https://david-runger-public-uploads.s3.amazonaws.com/resume.pdf</loc>
            </url>
            <url>
              <loc>http://davidrunger.com/insecure</loc>
            </url>
            <url>
              <loc>not a URL</loc>
            </url>
            <sitemap>
              <loc>https://davidrunger.com/sitemap.xml</loc>
            </sitemap>
          </urlset>
        XML
      )
    end

    it 'returns only HTTPS URLs from the site and does not revisit sitemaps' do
      expect(urls).to eq(['https://davidrunger.com/blog/'])

      expect(a_request(:get, sitemap_url)).to have_been_made.once
      expect(a_request(:get, 'https://davidrunger.com/nested-sitemap.xml')).to have_been_made.once
      expect(a_request(:get, 'https://example.com/sitemap.xml')).not_to have_been_made
    end

    it 'does not fetch a sitemap beyond the nesting limit' do
      sitemap_urls =
        (0..SitemapCrawler::MAX_SITEMAP_DEPTH).map do |depth|
          "https://davidrunger.com/sitemap-#{depth}.xml"
        end
      too_deep_sitemap_url = 'https://davidrunger.com/too-deep-sitemap.xml'

      sitemap_urls.each_with_index do |url, depth|
        nested_sitemap_url = sitemap_urls[depth + 1] || too_deep_sitemap_url
        page_url =
          if depth == SitemapCrawler::MAX_SITEMAP_DEPTH
            '<url><loc>https://davidrunger.com/at-depth-limit</loc></url>'
          end

        stub_request(:get, url).to_return(
          body: <<~XML,
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              #{page_url}
              <sitemap><loc>#{nested_sitemap_url}</loc></sitemap>
            </sitemapindex>
          XML
        )
      end

      expect(SitemapCrawler.new(sitemap_urls.first).urls).
        to eq(['https://davidrunger.com/at-depth-limit'])
      expect(a_request(:get, too_deep_sitemap_url)).not_to have_been_made
    end
  end
end
