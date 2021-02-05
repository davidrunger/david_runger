# frozen_string_literal: true

RSpec.describe TrackAssetSizes do
  subject(:worker) { TrackAssetSizes.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when system calls via `...` return a filesize', :frozen_time do
      before { expect(worker).to receive(:`).at_least(:once).and_return("#{stubbed_file_size}\n") }

      let(:stubbed_file_size) { rand(200_000) }

      it 'stores the asset size(s) in Redis' do
        expect {
          perform
        }.to change {
          RedisTimeseries['home*.js'].to_h
        }.from({}).
          to({ Time.current => stubbed_file_size })
      end
    end
  end
end
