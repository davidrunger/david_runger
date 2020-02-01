# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stats::Redis do
  subject(:worker) { Stats::Redis.new }

  # spy on and stub StatsD::gauge
  before { allow(StatsD).to receive(:gauge) }

  specify { expect(worker.class.ancestors).to include(Sidekiq::Worker) }

  describe '#track_databases' do
    subject(:track_databases) { worker.track_databases }

    context 'when a tracked database (e.g. db0) is not in the Redis info response' do
      before do
        # this does _not_ include 'db0'; we'll test that db0 still gets tracked
        expect(worker).to receive(:info_hash).
          at_least(:once).
          and_return('db1' => 'keys=10,expires=3,avg_ttl=106149604570')
      end

      it 'tracks that there are 0 keys in the empty database' do
        track_databases

        expect(StatsD).to have_received(:gauge).with('redis.db0.keys', 0)
      end

      it 'tracks that there are 0 expiring keys in the empty database' do
        track_databases

        expect(StatsD).to have_received(:gauge).with('redis.db0.expires', 0)
      end
    end

    context 'when a tracked database (e.g. db0) is in the Redis info response' do
      let(:key_count) { 23 }
      let(:expiring_key_count) { 45 }

      before do
        expect(worker).to receive(:info_hash).
          at_least(:once).
          and_return(
            'db0' => "keys=#{key_count},expires=#{expiring_key_count},avg_ttl=106149604570",
          )
      end

      it 'tracks the number of keys is stated by the Redis INFO data' do
        track_databases

        expect(StatsD).to have_received(:gauge).with('redis.db0.keys', key_count)
      end

      it 'tracks the number of expiring keys is stated by the Redis INFO data' do
        track_databases

        expect(StatsD).to have_received(:gauge).with('redis.db0.expires', expiring_key_count)
      end
    end
  end
end
