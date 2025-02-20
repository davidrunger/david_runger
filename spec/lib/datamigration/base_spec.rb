RSpec.describe(Datamigration::Base) do
  let(:datamigration) { described_class.new }
  let(:logdev) { datamigration.send(:logger).broadcasts.first.instance_variable_get(:@logdev) }

  before do
    allow(logdev).to receive(:write).and_call_original
  end

  context 'when Rails.logger.level is :info' do
    around do |spec|
      Rails.logger.with(level: :info) do
        spec.run
      end
    end

    describe '#logging_start_and_finish' do
      it 'logs start and finish messages around the given block' do
        result = nil

        datamigration.send(:logging_start_and_finish) do
          result = 'block executed'
        end

        expect(logdev).to have_received(:write).ordered.with(
          "[Datamigration::Base] Starting...\n",
        )
        expect(logdev).to have_received(:write).ordered.with(
          "[Datamigration::Base] Finished.\n",
        )
        expect(result).to eq('block executed')
      end

      it 'logs starting message and propagates any exceptions that occur' do
        expect do
          datamigration.send(:logging_start_and_finish) do
            raise('test error')
          end
        end.to raise_error('test error')

        expect(logdev).to have_received(:write).exactly(:once)
        expect(logdev).to have_received(:write).with(
          "[Datamigration::Base] Starting...\n",
        )
      end
    end

    # rubocop:disable RSpec/InstanceVariable
    describe '#within_transaction' do
      subject(:within_transaction) do
        @executed = false

        datamigration.send(:within_transaction, rollback:) do
          User.create!(email:)
          @executed = true
        end
      end

      let(:email) { 'datamigrationbasespec@example.com' }

      before { allow(ApplicationRecord).to receive(:transaction).and_call_original }

      context 'when :rollback is false' do
        let(:rollback) { false }

        it 'does not roll back the transaction' do
          within_transaction

          expect(User.where(email:)).to exist
          expect(@executed).to be(true)
          expect(ApplicationRecord).to have_received(:transaction)
        end
      end

      context 'when :rollback is true' do
        let(:rollback) { true }

        it 'executes the block and rolls back the transaction' do
          within_transaction

          expect(User.where(email:)).not_to exist
          expect(@executed).to be(true)
          expect(ApplicationRecord).to have_received(:transaction)
          expect(logdev).to have_received(:write).exactly(:once)
          expect(logdev).to have_received(:write).with(
            "[Datamigration::Base] Rolling back...\n",
          )
        end
      end
    end
    # rubocop:enable RSpec/InstanceVariable

    describe '#log' do
      it 'logs messages with class name tag' do
        datamigration.send(:log, 'test message')

        expect(logdev).to have_received(:write).exactly(:once)
        expect(logdev).to have_received(:write).with(
          "[Datamigration::Base] test message\n",
        )
      end
    end

    describe '#logger' do
      it 'memoizes the logger instance' do
        first_logger = datamigration.send(:logger)
        second_logger = datamigration.send(:logger)

        expect(first_logger.object_id).to eq(second_logger.object_id)
      end
    end
  end
end
