RSpec.describe 'handling 404s' do
  subject(:request_nonexistent_route) do
    get('/not-there', headers:)
  end

  context 'when production error handling is enabled', :production_like_error_handling do
    context 'when exceptions_app is set to routes' do
      before { expect(Rails.application.config.exceptions_app).to eq(Rails.application.routes) }

      context 'when the request includes a JSON-prioritizing Accept header (while also accepting other content types)' do
        let(:headers) { { 'Accept' => 'application/json, */*;q=0.5' } }

        it 'responds with a 404 status code and JSON content' do
          request_nonexistent_route

          expect(response).to have_http_status(404)
          expect(response.parsed_body).to eq({ 'error' => 'Not Found' })
        end
      end
    end
  end
end
