RSpec.describe('Rack::Attack') do
  describe 'public telemetry throttles' do
    Rack::Attack::PUBLIC_TELEMETRY_ENDPOINTS.each_key do |endpoint|
      context "when checking #{endpoint}" do
        subject(:throttle) { Rack::Attack.throttles.fetch("#{endpoint}/ip") }

        it 'allows a generous burst while bounding endpoint amplification' do
          expect(throttle.limit).to eq(Rack::Attack::PUBLIC_TELEMETRY_REQUEST_LIMIT)
          expect(throttle.period).to eq(1.minute)
        end

        it 'discriminates POST requests to the endpoint by IP address' do
          request = Rack::Attack::Request.new(
            Rack::MockRequest.env_for("/api/#{endpoint}", method: 'POST'),
          )

          expect(throttle.block.call(request)).to eq(request.ip)
        end

        it 'does not match other request methods' do
          request = Rack::Attack::Request.new(
            Rack::MockRequest.env_for("/api/#{endpoint}", method: 'GET'),
          )

          expect(throttle.block.call(request)).to be_nil
        end
      end
    end
  end

  describe 'log CSV upload throttle' do
    subject(:throttle) { Rack::Attack.throttles.fetch('logs/uploads/global') }

    it 'allows at most 30 uploads in an hour across all users' do
      expect(throttle.limit).to eq(Rack::Attack::LOG_CSV_UPLOAD_REQUEST_LIMIT)
      expect(throttle.period).to eq(1.hour)
    end

    it 'discriminates POST requests to all upload route variants together' do
      %w[/logs/uploads /logs/uploads.json /logs/uploads/].each do |path|
        request = Rack::Attack::Request.new(
          Rack::MockRequest.env_for(path, method: 'POST'),
        )

        expect(throttle.block.call(request)).to eq('all')
      end
    end

    it 'does not match other request methods or paths' do
      get_request = Rack::Attack::Request.new(Rack::MockRequest.env_for('/logs/uploads'))
      other_path_request = Rack::Attack::Request.new(
        Rack::MockRequest.env_for('/logs/anything', method: 'POST'),
      )
      nested_path_request = Rack::Attack::Request.new(
        Rack::MockRequest.env_for('/logs/uploads/archive', method: 'POST'),
      )

      expect(throttle.block.call(get_request)).to be_nil
      expect(throttle.block.call(other_path_request)).to be_nil
      expect(throttle.block.call(nested_path_request)).to be_nil
    end
  end

  describe 'notification logging' do
    it 'includes the matched rule and throttle usage' do
      request = Rack::Attack::Request.new(Rack::MockRequest.env_for('/api/events'))
      request.env['rack.attack.matched'] = 'events/ip'
      request.env['rack.attack.match_data'] = { count: 11, limit: 10 }

      allow(Rails.logger).
        to receive(:info).
        with(/matched=events\/ip match_count=11 match_limit=10/)

      ActiveSupport::Notifications.instrument('throttle.rack_attack', request:)

      expect(Rails.logger).
        to have_received(:info).once.
        with(/matched=events\/ip match_count=11 match_limit=10/)
    end
  end

  describe '::blocked_path?' do
    subject(:blocked_path?) { Rack::Attack.blocked_path?(request) }

    let(:request) do
      instance_double(
        Rack::Attack::Request,
        env: {},
        fullpath: request_path,
        path: request_path.split('?').first,
      )
    end

    context "when the request path includes \u0000" do
      let(:request_path) { "/junk?spam=other\u0000stuff" }

      it 'returns true' do
        expect(blocked_path?).to eq(true)
      end
    end

    context 'when the request includes a banned path fragment' do
      let(:banned_path_fragment_value) { BannedPathFragment.first!.value }

      context 'when the path does not begin with a whitelisted prefix' do
        let(:request_path) { "/auth/not_allowed?#{banned_path_fragment_value}" }

        it 'returns true' do
          expect(blocked_path?).to eq(true)
        end
      end

      context 'when the path begins with "/auth/failure?" (a whitelisted prefix)' do
        let(:request_path) { "/auth/failure?#{banned_path_fragment_value}" }

        it 'returns false' do
          expect(blocked_path?).to eq(false)
        end
      end
    end

    context "when the request path starts with '/sidekiq/'" do
      let(:request_path) { '/sidekiq/app.css' }

      it 'returns false' do
        expect(blocked_path?).to eq(false)
      end
    end

    context "when the request path is '/logs'" do
      let(:request) do
        instance_double(
          Rack::Attack::Request,
          fullpath: request_path,
          path: request_path,
        )
      end
      let(:request_path) { '/logs' }

      it 'returns false' do
        expect(blocked_path?).to eq(false)
      end
    end
  end

  describe '::fragments' do
    subject(:fragments) { Rack::Attack.send(:fragments, fullpath) }

    context 'when the fullpath is "/?q=(alevins)"' do
      let(:fullpath) { '/?q=(alevins)' }

      it 'returns the fragments' do
        expect(fragments).to eq(['q', '(alevins)'])
      end
    end
  end
end
