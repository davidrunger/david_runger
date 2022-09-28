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
  end
end
