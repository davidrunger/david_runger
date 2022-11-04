# frozen_string_literal: true

RSpec.describe SpacedLaunching do
  subject(:worker) { StubbedWorker.new }

  before do
    stub_const('StubbedWorker', Class.new)

    StubbedWorker.class_eval do
      include SpacedLaunching
    end
  end

  describe '#launch_with_spacing' do
    subject(:launch_with_spacing) do
      worker.send(
        :launch_with_spacing,
        worker_name: 'FetchIpInfoForRequest',
        arguments_list: [Faker::Internet.ip_v4_address] * 3,
        spacing_seconds:,
      )
    end

    context 'when the total spaced launch period exceeds the default maximum' do
      let(:spacing_seconds) { 1.hour + 1.second }

      it 'sends a warning to Rollbar' do
        expect(Rollbar).
          to receive(:warn).
          with(
            ApplicationWorker::MaxSpacingTimeExceeded,
            hash_including(:arguments_list, :max_total_spacing, :spacing_seconds),
          ).
          and_call_original

        launch_with_spacing
      end
    end

    context 'when the total spaced launch period does not exceed the default maximum' do
      let(:spacing_seconds) { 1.hour }

      it 'does not send a warning to Rollbar' do
        expect(Rollbar).not_to receive(:warn)

        launch_with_spacing
      end
    end
  end
end
