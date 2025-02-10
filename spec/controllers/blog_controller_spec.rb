RSpec.describe(BlogController) do
  include BlogSpecHelpers

  context 'when there is a 404 HTML file in the blog directory' do
    around do |example|
      with_blog_file('404.html', not_found_page_content) do
        example.run
      end
    end

    let(:not_found_page_content) { 'We cannot find that page' }

    describe '#index' do
      subject(:get_index) { get(:index) }

      context 'when index.html exists in the blog/ directory' do
        around do |example|
          with_blog_file('index.html', index_content) do
            example.run
          end
        end

        let(:index_content) { 'many posts are listed here' }

        it 'responds with 200 and the index file content' do
          get_index

          expect(response).to have_http_status(200)
          expect(response.body).to eq(index_content)
        end
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { format:, slug: }) }

      let(:format) { 'html' }
      let(:slug) { 'why-i-love-ruby' }

      context 'when requested without a specific content type' do
        let(:format) { nil }

        context 'when the requested file exists in the blog/ directory' do
          let(:show_content) { 'it is the best language ever' }

          around do |example|
            with_blog_file("#{slug}.html", show_content) do
              example.run
            end
          end

          it 'responds with 200 and the show file content' do
            get_show

            expect(response).to have_http_status(200)
            expect(response.body).to eq(show_content)
          end
        end

        context 'when the requested file does not exist in the blog/ directory' do
          let(:slug) { SecureRandom.uuid }

          it 'responds with 404 status and 404 page content' do
            get_show

            expect(response).to have_http_status(404)
            expect(response.body).to have_text(not_found_page_content)
          end

          it 'reports via Rails.error' do
            expect(Rails.error).
              to receive(:report).
              with(
                ActionController::RoutingError,
                context: hash_including(
                  relative_path: "/blog/#{slug}.html",
                ),
              ).
              and_call_original

            get_show
          end
        end
      end

      context 'when requested as JSON' do
        let(:format) { 'json' }

        it 'responds with 404 and no content' do
          get_show

          expect(response).to have_http_status(404)
          expect(response.body).to eq('')
        end

        it 'reports via Rails.error' do
          expect(Rails.error).
            to receive(:report).
            with(
              BlogController::InvalidShowRequestFormat,
              context: hash_including(request_format_symbol: :json),
            ).
            and_call_original

          get_show
        end
      end

      context 'when an attacker somehow submits a path that resolves outside of the blog directory' do
        before do
          # I cannot think of any way to actually test the relevant code, so use
          # allow_any_instance_of.
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Pathname).to receive(:realpath).and_return(path_outside_of_blog)
          # rubocop:enable RSpec/AnyInstance
        end

        let(:path_outside_of_blog) { '/etc/you-got-hacked.xml' }

        it 'responds with 404 status and 404 page content' do
          get_show

          expect(response).to have_http_status(404)
          expect(response.body).to have_text(not_found_page_content)
        end

        it 'reports via Rails.error' do
          expect(Rails.error).
            to receive(:report).
            with(
              BlogController::UnauthorizedBlogFileRequest,
              context: hash_including(
                absolute_path: path_outside_of_blog,
                relative_path: "/blog/#{slug}.html",
              ),
            ).
            and_call_original

          get_show
        end
      end
    end

    describe '#assets' do
      subject(:get_assets) { get(:assets, params: { path: asset_path }) }

      let(:asset_path) { '_bridgetown/static/index.QL2A.css' }

      context 'when the requested file exists in the blog/ directory' do
        let(:asset_content) { 'this is asset content' }

        around do |example|
          with_blog_file(asset_path, asset_content) do
            example.run
          end
        end

        it 'responds with 200' do
          get_assets

          expect(response).to have_http_status(200)
          expect(response.body).to eq(asset_content)
        end
      end
    end
  end
end
