# frozen_string_literal: true

RSpec.describe Prerenderable, :without_verifying_authorization do
  before { stub_const('LIVE_RENDERED_PAGE_TEXT', 'Good morning, Vietnam!') }

  controller(ApplicationController) do
    include Prerenderable

    skip_before_action :authenticate_user!

    def index
      serve_prerender_with_fallback(filename: 'home.html') do
        render(plain: LIVE_RENDERED_PAGE_TEXT)
      end
    end
  end

  describe '#serve_prerender_with_fallback' do
    subject(:get_index) { get(:index) }

    context 'when AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY ENV variables are set' do
      around do |spec|
        ClimateControl.modify(
          AWS_ACCESS_KEY_ID: 'HU49U3C3HUBKHCRQQ32L',
          AWS_SECRET_ACCESS_KEY: 'QRZ4jVBn3EqPrgtz2mKNb6XdMhULGSliA7w1scD8',
        ) do
          spec.run
        end
      end

      context 'when S3_REGION and S3_BUCKET ENV variables are set' do
        around do |spec|
          ClimateControl.modify(
            S3_REGION: 'us-east-1',
            S3_BUCKET: 'david-runger-test-uploads',
          ) do
            spec.run
          end
        end

        context 'when S3 responds with prerendered page content' do
          let(:page_text) { 'Great page text!' }

          before do
            stub_request(
              :get,
              'https://david-runger-test-uploads.s3.amazonaws.com/prerenders/home.html',
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

          context 'when the browser is Chrome' do
            let(:chrome_88_user_agent) do
              <<~USER_AGENT.squish
                Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1_0) AppleWebKit/537.36
                (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36
              USER_AGENT
            end

            before do
              request.headers['User-Agent'] = chrome_88_user_agent

              browser = Browser.new(chrome_88_user_agent)
              expect(browser).to be_chrome
            end

            it 'serves the prerendered page with `html.webp`' do
              get_index
              expect(response.body).to have_css('html.webp')
            end
          end

          context 'when Rails.env is "development"' do
            before do
              expect(Rails).
                to receive(:env).
                at_least(:once).
                and_return(ActiveSupport::EnvironmentInquirer.new('development'))
            end

            it 'serves the prerendered page' do
              get_index
              expect(response.body).to have_text(page_text)
            end
          end
        end

        context 'when S3 responds with an Aws::S3::Errors::NoSuchKey error' do
          before do
            expect_any_instance_of(Aws::S3::Object). # rubocop:disable RSpec/AnyInstance
              to receive(:get).
              and_raise(Aws::S3::Errors::NoSuchKey.allocate)
          end

          it 'serves the page via the fallback block' do
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

      context 'when S3_REGION is not set' do
        before { expect(ENV['S3_REGION']).to eq(nil) }

        context 'when Rails.env is "test"' do
          before { expect(Rails.env).to eq('test') }

          it 'raises an error' do
            expect { get_index }.to raise_error(Aws::Errors::MissingRegionError)
          end
        end

        context 'when Rails.env is "production"' do
          before do
            expect(Rails).
              to receive(:env).
              at_least(:once).
              and_return(ActiveSupport::EnvironmentInquirer.new('production'))
          end

          it 'logs to Rollbar' do
            expect(Rollbar).to receive(:error).with(
              Aws::Errors::MissingRegionError,
              filename: 'home.html',
            ).and_call_original
            get_index
          end
        end

        context 'when Rails.env is "development"' do
          before do
            expect(Rails).
              to receive(:env).
              at_least(:once).
              and_return(ActiveSupport::EnvironmentInquirer.new('development'))
          end

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
