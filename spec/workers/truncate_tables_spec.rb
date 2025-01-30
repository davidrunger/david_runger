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

    context 'when there is at least one row in the `ip_blocks` table' do
      before { expect(IpBlock.count).to be > 0 }

      it 'issues a DELETE command against the `ip_blocks` table' do
        allow(@connection).to receive(:execute).and_call_original

        perform

        expect(@connection).
          to have_received(:execute).
          with(/DELETE FROM ip_blocks/)
      end
    end

    context 'when there are no rows in the `ip_blocks` table' do
      before { IpBlock.delete_all }

      it 'does not issue a DELETE command against the `ip_blocks` table' do
        expect(@connection).
          not_to receive(:execute).
          with(/DELETE FROM ip_blocks/i)

        # pass other calls through
        allow(@connection).to receive(:execute).and_call_original

        perform
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
