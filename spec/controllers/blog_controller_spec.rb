# frozen_string_literal: true

RSpec.describe(BlogController) do
  context 'when a BLOG_ROOT_URL env var is set' do
    let(:blog_host_url) { 'https://my-blog.static-host.com' }

    let(:blog_path) { 'blog' }

    around do |spec|
      ClimateControl.modify(BLOG_ROOT_URL: blog_host_url) do
        spec.run
      end
    end

    describe '#index' do
      subject(:get_index) { get(:index) }

      context 'when the blog server responds with blog index content' do
        before do
          stub_request(:get, "#{blog_host_url}/#{blog_path}").
            with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip',
                'Connection' => 'keep-alive',
                'User-Agent' => 'Ruby',
              },
            ).
            to_return(status: 200, body: 'great blog content', headers: {})
        end

        it 'responds with 200' do
          get_index
          expect(response).to have_http_status(200)
        end
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { slug: }) }

      let(:slug) { 'why-i-love-ruby' }

      context 'when the blog server responds with blog show content' do
        before do
          stub_request(:get, "#{blog_host_url}/#{blog_path}/#{slug}").
            with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip',
                'Connection' => 'keep-alive',
                'User-Agent' => 'Ruby',
              },
            ).
            to_return(status: 200, body: 'great blog content', headers: {})
        end

        it 'responds with 200' do
          get_show
          expect(response).to have_http_status(200)
        end
      end
    end

    describe '#assets' do
      subject(:get_assets) { get(:assets, params: { path: asset_path }) }

      let(:asset_path) { '_bridgetown/static/index.QL2A.css' }

      context 'when the blog server responds with blog show content' do
        before do
          stub_request(:get, "#{blog_host_url}/#{blog_path}/#{asset_path}").
            with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip',
                'Connection' => 'keep-alive',
                'User-Agent' => 'Ruby',
              },
            ).
            to_return(status: 200, body: 'great blog content', headers: {})
        end

        it 'responds with 200' do
          get_assets
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
