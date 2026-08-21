RSpec.describe 'Blog requests' do
  include BlogSpecHelpers

  describe 'GET /blog/some-article' do
    subject(:get_blog_article) { get('/blog/some-article', headers:) }

    let(:headers) { {} }

    context 'when an HTML file exists that matches the requested path' do
      around do |spec|
        with_blog_file('some-article.html', '<html><head></head><body></body></html>') do
          spec.run
        end
      end

      context 'when there is an Accept header for HTML and Atom formats' do
        let(:headers) { { 'Accept' => 'text/html, application/atom+xml' } }

        it 'responds successfully with an HTML content type', :aggregate_failures do
          get_blog_article

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

  describe 'GET requests containing path traversal' do
    let(:sibling_directory_name) { "blog_#{SecureRandom.hex}" }
    let(:sibling_directory) { Rails.root.join(sibling_directory_name) }
    let(:sensitive_file) { sibling_directory.join('sensitive.xml') }
    let(:sensitive_content) { '<sensitive>content</sensitive>' }

    around do |example|
      FileUtils.mkdir(sibling_directory)
      File.write(sensitive_file, sensitive_content)

      with_blog_file('404.html', 'Not found') do
        example.run
      end
    ensure
      FileUtils.rm_f(sensitive_file)
      if sibling_directory.exist?
        FileUtils.rmdir(sibling_directory)
      end
    end

    it 'rejects a canonical path in a sibling whose name starts with "blog"' do
      link = Rails.root.join('blog', sibling_directory_name)
      FileUtils.ln_s(sibling_directory, link)

      get("/blog/#{sibling_directory_name}/sensitive.xml")

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(sensitive_content)
    ensure
      FileUtils.rm_f(link)
    end

    it 'rejects percent-encoded dot segments' do
      get("/blog/%2e%2e/#{sibling_directory_name}/sensitive.xml")

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(sensitive_content)
    end

    it 'rejects percent-encoded dot segments and separators' do
      get("/blog/%2E%2E%2F#{sibling_directory_name}%2Fsensitive.xml")

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(sensitive_content)
    end
  end
end
