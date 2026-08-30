RSpec.describe TruncateTables do
  subject(:worker) { TruncateTables.new }

  # rubocop:disable-next RSpec/InstanceVariable
  describe '#perform' do
    subject(:perform) { worker.perform }

    around do |spec|
      ApplicationRecord.with_connection do |connection|
        @connection = connection
        spec.run
      end
    end

    it 'applies bounded retention to CSP reports but not events or requests', :frozen_time do
      allow(described_class).to receive(:truncate)

      perform

      expect(described_class).
        to have_received(:truncate).
        with(
          table: 'csp_reports',
          timestamp: 'created_at',
          min_surviving_timestamp: described_class::CSP_REPORT_RETENTION_PERIOD.ago,
          max_allowed_rows: described_class::CSP_REPORT_MAX_ROWS,
        )
      expect(described_class).
        not_to have_received(:truncate).
        with(hash_including(table: 'events'))
      expect(described_class).
        not_to have_received(:truncate).
        with(hash_including(table: 'requests'))
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
end
