RSpec.describe DataMonitors::Users do
  subject(:worker) { DataMonitors::Users.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    it 'verifies some data expectations' do
      allow(worker).to receive(:verify_data_expectation).and_call_original
      perform

      expect(worker).to have_received(:verify_data_expectation).at_least(:twice)
    end
  end
end
