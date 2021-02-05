# frozen_string_literal: true

RSpec.describe RedisTimeseries do
  subject(:timeseries) { RedisTimeseries[timeseries_name] }

  let(:timeseries_name) { 'test-timeseries' }

  describe '#to_h' do
    subject(:to_h) { timeseries.to_h }

    context 'when there is timeseries data in redis', :frozen_time do
      before { timeseries.add(timeseries_sample_value) }

      let(:timeseries_sample_value) { rand(100) }

      it 'returns a hash in the form { Time => value }' do
        expect(to_h).to eq({ Time.current => timeseries_sample_value })
      end
    end
  end
end
