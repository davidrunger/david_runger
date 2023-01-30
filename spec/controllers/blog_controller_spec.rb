# frozen_string_literal: true

RSpec.describe(BlogController) do
  context 'when a BLOG_ROOT_URL env var is set' do
    let(:blog_host_url) { 'https://my-blog.static-host.com' }

    around do |spec|
      ClimateControl.modify(BLOG_ROOT_URL: blog_host_url) do
        spec.run
      end
    end

    context 'when the blog server responds with content' do
      before do
        stub_request(:get, blog_host_url).
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip',
              'Connection' => 'keep-alive',
              'Content-Length' => '0',
              'User-Agent' => 'Ruby',
            },
          ).
          to_return(status: 200, body: 'great blog content', headers: {})
      end

      describe '#index' do
        subject(:get_index) { get(:index) }

        it 'responds with 200' do
          get_index
          expect(response).to have_http_status(200)
        end
      end

      describe '#show' do
        subject(:get_show) { get(:show, params: { slug: 'why-i-love-ruby' }) }

        it 'responds with 200' do
          get_show
          expect(response).to have_http_status(200)
        end
      end

      describe '#assets' do
        subject(:get_assets) { get(:assets, params: { path: '_bridgetown/static/index.QL2A.css' }) }

        it 'responds with 200' do
          get_assets
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
