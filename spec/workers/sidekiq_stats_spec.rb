# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidekiqStats do
  subject(:worker) { SidekiqStats.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    it 'calls StatsD.gauge with a bunch of arguments' do
      SidekiqStats::OVERALL_STATS.each do |stat_name|
        expect(StatsD).to receive(:gauge).with("sidekiq.#{stat_name}", Numeric).and_call_original
      end

      SIDEKIQ_QUEUES.each do |queue_name|
        expect(StatsD).to receive(:gauge).
          with("sidekiq.#{queue_name}.size", Numeric).
          and_call_original
        expect(StatsD).to receive(:gauge).
          with("sidekiq.#{queue_name}.latency", Numeric).
          and_call_original
      end

      perform
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
  end
end
