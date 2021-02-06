# frozen_string_literal: true

RSpec.describe DataMonitors::HomeIndexRequests do
  subject(:worker) { DataMonitors::HomeIndexRequests.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    it 'verifies some data expectations' do
      expect(worker).to receive(:verify_data_expectation).at_least(:twice).and_call_original
      perform
    end
  end
end
