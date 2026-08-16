RSpec.describe 'Public telemetry ingestion', :cache, :rack_test_driver do
  around do |spec|
    expect(Rails.cache).to be_a(ActiveSupport::Cache::MemoryStore)

    Rack::Attack.cache.with(store: Rails.cache) do
      spec.run
    end
  end

  {
    '/api/csp_reports' => CspReport,
    '/api/events' => Event,
  }.each do |path, model|
    context "when POST #{path} has an oversized body" do
      it 'returns 413 without persisting telemetry' do
        expect {
          page.driver.post(
            path,
            'a' * (Middleware::PublicTelemetryBodyLimiter::MAX_BODY_BYTES + 1),
            'CONTENT_TYPE' => 'application/json',
          )
        }.not_to change { model.count }

        expect(page.status_code).to eq(413)
      end
    end
  end

  context 'when an IP posts more than ten Events in one minute', :frozen_time do
    let(:event_body) { { data: { page_url: DavidRunger::CANONICAL_URL }, type: 'scroll' }.to_json }

    it 'returns 429 for the eleventh request without creating another Event' do
      expect {
        Rack::Attack::PUBLIC_TELEMETRY_REQUEST_LIMIT.times do
          page.driver.post(
            '/api/events',
            event_body,
            'CONTENT_TYPE' => 'application/json',
          )
          expect(page.status_code).to eq(201)
        end
      }.to change { Event.count }.by(Rack::Attack::PUBLIC_TELEMETRY_REQUEST_LIMIT)

      expect {
        page.driver.post(
          '/api/events',
          event_body,
          'CONTENT_TYPE' => 'application/json',
        )
      }.not_to change { Event.count }

      expect(page.status_code).to eq(429)
    end
  end
end
