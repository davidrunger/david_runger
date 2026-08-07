RSpec.describe Middleware::PublicTelemetryBodyLimiter do
  subject(:response) { described_class.new(app).call(env) }

  let(:app) do
    lambda do |app_env|
      [200, {}, [app_env.fetch('rack.input').read]]
    end
  end
  let(:body) { 'a' * described_class::MAX_BODY_BYTES }
  let(:env) { Rack::MockRequest.env_for(path, method:, input: body) }
  let(:method) { 'POST' }
  let(:path) { '/api/events' }

  context 'when a telemetry POST body is exactly the maximum size' do
    it 'rewinds the body and passes the request to the application' do
      expect(response).to eq([200, {}, [body]])
    end
  end

  context 'when a telemetry POST declares an oversized body' do
    let(:body) { 'a' * (described_class::MAX_BODY_BYTES + 1) }

    it 'returns 413 without calling the application' do
      expect(app).not_to receive(:call)

      expect(response).to match([
        413,
        hash_including('content-length', 'content-type'),
        [described_class::TOO_LARGE_BODY],
      ])
    end
  end

  context 'when a telemetry POST understates its oversized body length' do
    let(:body) { 'a' * (described_class::MAX_BODY_BYTES + 1) }
    let(:env) do
      super().tap { it['CONTENT_LENGTH'] = '1' }
    end

    it 'returns 413 after bounded reading without calling the application' do
      expect(app).not_to receive(:call)
      expect(response.first).to eq(413)
    end
  end

  context 'when a formatted CSP report path has an oversized body' do
    let(:body) { 'a' * (described_class::MAX_BODY_BYTES + 1) }
    let(:path) { '/api/csp_reports.json/' }

    it 'returns 413' do
      expect(response.first).to eq(413)
    end
  end

  context 'when another path has an oversized body' do
    let(:body) { 'a' * (described_class::MAX_BODY_BYTES + 1) }
    let(:path) { '/api/logs' }

    it 'passes the request to the application' do
      expect(response).to eq([200, {}, [body]])
    end
  end

  context 'when a telemetry path receives a non-POST request with an oversized body' do
    let(:body) { 'a' * (described_class::MAX_BODY_BYTES + 1) }
    let(:method) { 'PUT' }

    it 'passes the request to the application' do
      expect(response).to eq([200, {}, [body]])
    end
  end
end
