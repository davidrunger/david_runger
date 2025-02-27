RSpec.describe 'Blog requests' do
  include BlogSpecHelpers

  describe 'GET /blog/some-article' do
    subject(:get_blog_feed) { get('/blog/some-article', headers:) }

    let(:headers) { {} }

    context 'when an HTML file exists that matches the requested path' do
      around do |spec|
        with_blog_file('some-article.html', '<html><head></head><body></body></html>') do
          spec.run
        end
      end

      context 'when there is an Accept header for HTML, and Atom formats' do
        let(:headers) { { 'Accept' => 'text/html, application/atom+xml' } }

        it 'responds successfully with an HTML content type', :aggregate_failures do
          get_blog_feed

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html; charset=utf-8')
        end
      end
    end
  end

  describe 'GET /blog/feed.xml?test=true' do
    subject(:get_blog_feed) { get('/blog/feed.xml?test=true', headers:) }

    let(:headers) { {} }

    context 'when an XML file exists for the Atom feed' do
      around do |spec|
        with_blog_file('feed.xml', '<?xml version="1.0" encoding="utf-8"?>') do
          spec.run
        end
      end

      context 'when there is an Accept header for Atom, RSS, JSON, and any formats' do
        let(:headers) do
          {
            'Accept' =>
              'application/atom+xml, application/rss+xml, application/json, */*;q=0.1',
          }
        end

        it 'responds successfully with an XML content type', :aggregate_failures do
          get_blog_feed

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/xml')
        end
      end
    end
  end
end
