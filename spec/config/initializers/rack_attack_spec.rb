RSpec.describe('Rack::Attack') do
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
