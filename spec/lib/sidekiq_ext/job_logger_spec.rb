RSpec.describe SidekiqExt::JobLogger do
  subject(:logger) { SidekiqExt::JobLogger.new(Sidekiq.default_configuration) }

  describe '#call' do
    subject(:call) { logger.call(item, queue, &job_block) }

    # Sidekiq usually does this automatically when a job raises an error, but since we aren't fully
    # running jobs here (just calling the logger), we'll do it manually.
    after { Thread.current[:sidekiq_context] = nil }

    let(:item) do
      {
        'retry' => true,
        'queue' => 'default',
        'args' => [ip_address],
        'class' => 'CreateIpBlock',
        'jid' => SecureRandom.hex(12),
        'created_at' => (Time.current.to_f * 1_000).round,
        'enqueued_at' => (Time.current.to_f * 1_000).round,
      }
    end
    let(:ip_address) { Faker::Internet.ip_v4_address }
    let(:queue) { 'default' }

    context 'when the executed job does not raise an error' do
      let(:job_block) { proc { Rails.logger.debug('Performing the work ... !') } }

      it 'prints start job info, executes the block, and prints done job info' do
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(/queue=default args=\["#{ip_address}"\]: start\n\z/).
          and_call_original
        allow(Rails.logger).to receive(:debug).with('Performing the work ... !')
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(/queue=default args=\["#{ip_address}"\] elapsed=\d+\.\d{1,3}: done\n\z/).
          and_call_original

        call

        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(/queue=default args=\["#{ip_address}"\]: start\n\z/)
        expect(Rails.logger).to have_received(:debug).once.with('Performing the work ... !')
        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(/queue=default args=\["#{ip_address}"\] elapsed=\d+\.\d{1,3}: done\n\z/)
      end

      context 'when the job arguments are lengthy' do
        let(:ip_address) { ('123.' * 300).remove(/\.\z/) }

        it 'logs an abbreviated version of the job arguments' do
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(/queue=default args=\["#{'123.' * 34}12...\]: start\n\z/).
            and_call_original
          allow(Rails.logger).to receive(:debug).with('Performing the work ... !')
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(/args=\["#{'123.' * 34}12...\] elapsed=\d+\.\d{1,3}: done\n\z/).
            and_call_original

          call

          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(/queue=default args=\["#{'123.' * 34}12...\]: start\n\z/)
          expect(Rails.logger).to have_received(:debug).once.with('Performing the work ... !')
          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(/args=\["#{'123.' * 34}12...\] elapsed=\d+\.\d{1,3}: done\n\z/)
        end
      end

      context 'when job arguments contain filtered content' do
        let(:ip_address) { 'private message' }

        it 'does not emit the original content in Sidekiq log lines' do
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(/queue=default args=\["\[FILTERED: 15 bytes\]"\]: start\n\z/).
            and_call_original
          allow(Rails.logger).to receive(:debug).with('Performing the work ... !')
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(/args=\["\[FILTERED: 15 bytes\]"\] elapsed=\d+\.\d{1,3}: done\n\z/).
            and_call_original

          call

          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(/queue=default args=\["\[FILTERED: 15 bytes\]"\]: start\n\z/)
          expect(Rails.logger).to have_received(:debug).once.with('Performing the work ... !')
          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(/args=\["\[FILTERED: 15 bytes\]"\] elapsed=\d+\.\d{1,3}: done\n\z/)
        end
      end
    end

    context 'when the executed job raises an error' do
      let(:job_block) { proc { raise('A problem occurred in the Sidekiq job!') } }

      it 'prints start job info, executes the block, and prints failed job info' do
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(/queue=default args=\["#{ip_address}"\]: start\n\z/).
          and_call_original
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(/queue=default args=\["#{ip_address}"\] elapsed=\d+\.\d{1,3}: fail\n\z/).
          and_call_original

        expect { call }.to raise_error(/A problem occurred in the Sidekiq job!/)

        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(/queue=default args=\["#{ip_address}"\]: start\n\z/)
        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(/queue=default args=\["#{ip_address}"\] elapsed=\d+\.\d{1,3}: fail\n\z/)
      end
    end
  end
end
