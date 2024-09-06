RSpec.describe TruncateTables do
  subject(:worker) { TruncateTables.new }

  # rubocop:disable RSpec/InstanceVariable
  describe '#perform' do
    subject(:perform) { worker.perform }

    around do |spec|
      ApplicationRecord.with_connection do |connection|
        @connection = connection
        spec.run
      end
    end

    context 'when there is at least one row in the `requests` table' do
      before { expect(Request.count).to be > 0 }

      it 'issues a DELETE command against the `requests` table' do
        expect(@connection).to receive(:execute).
          with(/DELETE FROM requests/).
          and_call_original

        # pass other calls through
        allow(@connection).to receive(:execute).and_call_original

        perform
      end
    end

    context 'when there are no rows in the `requests` table' do
      before { Request.delete_all }

      it 'does not issue a DELETE command against the `requests` table' do
        expect(@connection).
          not_to receive(:execute).
          with(/DELETE FROM requests/i)

        # pass other calls through
        allow(@connection).to receive(:execute).and_call_original

        perform
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
