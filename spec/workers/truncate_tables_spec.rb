# frozen_string_literal: true

RSpec.describe TruncateTables do
  subject(:worker) { TruncateTables.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when there is at least one row in the `requests` table' do
      before { expect(Request.count).to be > 0 }

      it 'issues a DELETE command against the `requests` table' do
        expect(ApplicationRecord.connection).to receive(:execute).
          with(/DELETE FROM requests/).
          and_call_original

        # pass other calls through
        allow(ApplicationRecord.connection).to receive(:execute).and_call_original

        perform
      end
    end
  end
end
