# frozen_string_literal: true

RSpec.describe Api::CspReportsController do
  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:params) do
      {
        'csp-report' => {
          'document-uri' => 'http://example.com/signup.html',
          'referrer' => '',
          'blocked-uri' => 'http://example.com/css/style.css',
          'violated-directive' => 'style-src cdn.example.com',
          'original-policy' =>
            "default-src 'none'; style-src cdn.example.com; report-uri /_/csp-reports",
          'disposition' => 'report',
        },
      }
    end

    it 'returns a 204 status code' do
      post_create
      expect(response).to have_http_status(204)
    end

    it 'creates that item for the store' do
      expect { post_create }.to change { CspReport.count }.by(1)
    end

    context 'when the user agent is DuckDuckBot' do
      before do
        request.headers['User-Agent'] =
          "'DuckDuckBot-Https/1.1; (+https://duckduckgo.com/duckduckbot)'"
      end

      it 'does not send an error to Rollbar' do
        expect(Rollbar).not_to receive(:error)

        post_create
      end
    end

    context 'when the user agent is Firefox' do
      before do
        request.headers['User-Agent'] =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:105.0) ' \
          'Gecko/20100101 Firefox/105.0'
      end

      it 'sends an error to Rollbar' do
        expect(Rollbar).to receive(:error).with(CspViolation, hash_including(:csp_report_params))

        post_create
      end
    end
  end
end
