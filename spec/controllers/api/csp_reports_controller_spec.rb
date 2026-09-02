RSpec.describe Api::CspReportsController do
  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:params) do
      {
        'csp-report' => {
          'document-uri' => 'http://test.host/signup.html',
          'referrer' => '',
          'blocked-uri' => 'http://example.com/css/style.css',
          'violated-directive' => 'style-src cdn.example.com',
          'original-policy' =>
            "default-src 'none'; style-src cdn.example.com; report-uri /_/csp-reports",
          'disposition' => 'report',
        },
      }
    end
    let(:user_agent) do
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:105.0) Gecko/20100101 Firefox/105.0'
    end

    before { request.headers['User-Agent'] = user_agent }

    it 'returns a 204 status code' do
      post_create
      expect(response).to have_http_status(204)
    end

    it 'creates a CSP report' do
      expect { post_create }.to change { CspReport.count }.by(1)
    end

    it 'does not send the public report to the error-reporting service' do
      allow(Rails.error).to receive(:report)
      post_create

      expect(Rails.error).not_to have_received(:report)
    end

    it 'records the user agent' do
      post_create
      expect(CspReport.last!.user_agent).to eq(user_agent)
    end

    context 'when the document URI has a different origin' do
      before { params['csp-report']['document-uri'] = 'https://attacker.example/path' }

      it 'returns 422 without creating a CSP report' do
        expect { post_create }.not_to change { CspReport.count }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the document URI is invalid' do
      before { params['csp-report']['document-uri'] = 'https://not a URI' }

      it 'returns 422 without creating a CSP report' do
        expect { post_create }.not_to change { CspReport.count }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the document URI is not an HTTP URL' do
      before { params['csp-report']['document-uri'] = 'ftp://test.host/report' }

      it 'returns 422 without creating a CSP report' do
        expect { post_create }.not_to change { CspReport.count }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the CSP report root object is missing' do
      let(:params) { { 'other-report' => {} } }

      it 'returns 400 without creating a CSP report' do
        expect { post_create }.not_to change { CspReport.count }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the body contains malformed JSON' do
      subject(:post_create) { process(:create, method: :post, body: '{') }

      it 'returns 400 without creating a CSP report' do
        expect { post_create }.not_to change { CspReport.count }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when a CSP report field is too long' do
      before do
        params['csp-report']['original-policy'] =
          'a' * (CspReport::MAX_ORIGINAL_POLICY_LENGTH + 1)
      end

      it 'returns 422 without creating a CSP report' do
        expect { post_create }.not_to change { CspReport.count }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
