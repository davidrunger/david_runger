RSpec.describe Prerenderable, :without_verifying_authorization do
  before do
    stub_const('EXPECTED_CONTENT', 'Great page text!')
    stub_const('LIVE_RENDERED_PAGE_TEXT', 'Good morning, Vietnam!')
  end

  controller(ApplicationController) do
    include Prerenderable

    skip_before_action :authenticate_user!

    def index
      serve_prerender_with_fallback(filename: 'home.html', expected_content: EXPECTED_CONTENT) do
        render(plain: LIVE_RENDERED_PAGE_TEXT)
      end
    end
  end

  describe '#serve_prerender_with_fallback', :fake_aws_credentials do
    subject(:get_index) { get(:index, params:) }

    let(:params) { {} }

    context 'when ENV["GIT_REV"] is set' do
      around do |spec|
        ClimateControl.modify(GIT_REV: commit_sha) do
          spec.run
        end
      end

      let(:commit_sha) { Digest::SHA1.hexdigest(rand(1_000_000).to_s) }

      context 'when S3 responds with prerendered page content' do
        let(:page_text) { 'Great page text!' }

        before do
          stub_request(
            :get,
            'https://david-runger-uploads.s3.amazonaws.com/' \
            "prerenders/#{commit_sha}/home.html",
          ).to_return(status: 200, headers: {}, body: <<~HTML)
            <!doctype html>
            <html>
              <head>
                <meta charset="utf-8">
                <title>Title</title>
              </head>
              <body>
                <p>#{page_text}</p>
              </body>
            </html>
          HTML
        end

        it 'serves the prerendered page' do
          get_index
          expect(response.body).to have_text(page_text)
        end

        context 'when the prerender does not include the expected content' do
          let(:page_text) { 'There was an error!' }

          it 'live-renders the page rather than serving the prerender' do
            expect(Rails.logger).
              to receive(:info).
              with(/prerender was found, but it did not include/).
              and_call_original
            expect(Rails.logger).to receive(:info).at_least(:once).and_call_original # pass others

            get_index

            expect(response.body).to have_text(LIVE_RENDERED_PAGE_TEXT)
          end
        end

        context 'when Rails.env is "development"', rails_env: :development do
          it 'serves the prerendered page' do
            get_index
            expect(response.body).to have_text(page_text)
          end
        end
      end

      context 'when S3 will respond with an Aws::S3::Errors::NoSuchKey error' do
        before do
          allow_any_instance_of(Aws::S3::Object). # rubocop:disable RSpec/AnyInstance
            to receive(:get).
            and_raise(Aws::S3::Errors::NoSuchKey.allocate)
        end

        context 'when deploy fallback content including the expected content has been written to the cache', :cache do
          before do
            Rails.cache.write(
              PrerenderUtils.cache_key(
                git_rev: 'deploy-fallback',
                filename: 'home.html',
              ),
              cached_deploy_fallback_html,
            )
          end

          let(:cached_deploy_fallback_html) do
            "<html>#{EXPECTED_CONTENT} Deploy fallback markup!</html>"
          end

          context 'when a "prerender" query param is present' do
            let(:params) { super().merge({ prerender: true }) }

            it 'serves the page via the fallback block' do
              allow(Rails.logger).to receive(:info).and_call_original

              get_index

              expect(response.body).to eq(LIVE_RENDERED_PAGE_TEXT)
              expect(Rails.logger).to have_received(:info).with(
                'Skipping prerendered content because a prerender param is present.',
              )
            end
          end

          context 'when a "prerender" query param is not present' do
            before do
              expect(params.symbolize_keys).not_to have_key(:prerender)
            end

            it 'serves the cached, deploy-fallback content' do
              get_index

              expect(response.body).to eq(cached_deploy_fallback_html)
            end
          end
        end

        context 'when a deploy fallback has not been written to the cache' do
          before do
            expect(Rails.cache.read(
              PrerenderUtils.cache_key(
                git_rev: 'deploy-fallback',
                filename: 'home.html',
              ),
            )).to eq(nil)
          end

          it 'serves the page via the fallback block' do
            expect(Rails.logger).
              to receive(:info).
              with(%(Could not find a "home.html" prerender.)).
              and_call_original
            expect(Rails.logger).to receive(:info).at_least(:once).and_call_original # pass others

            get_index
            expect(response.body).to have_text(LIVE_RENDERED_PAGE_TEXT)
          end

          it 'does not log an error to Rollbar' do
            expect(Rollbar).not_to receive(:error)
            get_index
          end

          it 'logs to Rails.logger' do
            expect(Rails.logger).to receive(:warn).with(
              /Could not fetch prerendered content/,
            ).and_call_original
            get_index
          end
        end
      end

      context 'when getting the prerender raises a missing credentials error' do
        before do
          expect_any_instance_of(Aws::S3::Object). # rubocop:disable RSpec/AnyInstance
            to receive(:get).
            and_raise(Aws::Sigv4::Errors::MissingCredentialsError)
        end

        context 'when Rails.env is "test"' do
          before { expect(Rails.env).to eq('test') }

          it 'raises an error' do
            expect { get_index }.to raise_error(Aws::Sigv4::Errors::MissingCredentialsError)
          end
        end

        context 'when Rails.env is "production"', rails_env: :production do
          it 'reports via Rails.error' do
            expect(Rails.error).
              to receive(:report).
              with(
                Aws::Sigv4::Errors::MissingCredentialsError,
                severity: :error,
                context: { filename: 'home.html' },
              ).and_call_original

            get_index
          end
        end

        context 'when Rails.env is "development"', rails_env: :development do
          it 'logs to Rails.logger' do
            expect(Rails.logger).to receive(:warn).with(
              /Could not fetch prerendered content/,
            ).and_call_original
            get_index
          end
        end
      end
    end
  end
end
