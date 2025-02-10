RSpec.describe 'Traffic Advice' do
  describe 'GET /.well-known/traffic-advice' do
    it 'returns correct content type and body' do
      get '/.well-known/traffic-advice'

      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('application/trafficadvice+json')

      body = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
      expect(body).to eq([
        {
          'user_agent' => 'prefetch-proxy',
          'fraction' => 1.0,
        },
      ])
    end
  end
end
