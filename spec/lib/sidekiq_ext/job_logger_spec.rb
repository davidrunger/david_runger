RSpec.describe SidekiqExt::JobLogger do
  subject(:logger) { SidekiqExt::JobLogger.new(Sidekiq.default_configuration) }

  describe '#call' do
    subject(:call) { logger.call(item, queue, &job_block) }

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
    let(:memory_fields_before) do
      '(?:[ ]process_memory_kib_before=\d+)?[ ]heap_allocated_pages_before=\d+'
    end
    let(:memory_fields_after) do
      '(?:[ ]process_memory_kib_after=\d+)?[ ]heap_allocated_pages_after=\d+' \
        '(?:[ ]process_memory_kib_delta=-?\d+)?[ ]heap_allocated_pages_delta=-?\d+'
    end

    # Sidekiq usually does this automatically when a job raises an error, but since we aren't fully
    # running jobs here (just calling the logger), we'll do it manually.
    after { Thread.current[:sidekiq_context] = nil }

    context 'when the executed job does not raise an error' do
      let(:job_block) { proc { Rails.logger.debug('Performing the work ... !') } }

      it 'prints start job info, executes the block, and prints done job info' do
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(/queue=default args=\["#{ip_address}"\]#{memory_fields_before}: start\n\z/).
          and_call_original
        allow(Rails.logger).to receive(:debug).with('Performing the work ... !')
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(
            %r{
              queue=default[ ]args=\["#{ip_address}"\]
              #{memory_fields_before}
              \s+
              elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]done\n\z
            }x,
          ).
          and_call_original

        call

        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(/queue=default args=\["#{ip_address}"\]#{memory_fields_before}: start\n\z/)
        expect(Rails.logger).to have_received(:debug).once.with('Performing the work ... !')
        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(
            %r{
              queue=default[ ]args=\["#{ip_address}"\]
              #{memory_fields_before}
              \s+
              elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]done\n\z
            }x,
          )
      end

      context 'when the job arguments are lengthy' do
        let(:ip_address) { ('123.' * 300).remove(/\.\z/) }

        it 'logs an abbreviated version of the job arguments' do
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(/queue=default args=\["#{'123.' * 34}12...\]#{memory_fields_before}: start\n\z/).
            and_call_original
          allow(Rails.logger).to receive(:debug).with('Performing the work ... !')
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(
              %r{
                args=\["#{'123.' * 34}12...\]
                #{memory_fields_before}
                \s+
                elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]done\n\z
              }x,
            ).
            and_call_original

          call

          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(/queue=default args=\["#{'123.' * 34}12...\]#{memory_fields_before}: start\n\z/)
          expect(Rails.logger).to have_received(:debug).once.with('Performing the work ... !')
          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(
              %r{
                args=\["#{'123.' * 34}12...\]
                #{memory_fields_before}
                \s+
                elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]done\n\z
              }x,
            )
        end
      end

      context 'when job arguments contain filtered content' do
        let(:ip_address) { 'private message' }

        it 'does not emit the original content in Sidekiq log lines' do
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(
              %r{
                queue=default[ ]args=\["\[FILTERED:[ ]15[ ]bytes\]"\]
                #{memory_fields_before}:[ ]start\n\z
              }x,
            ).
            and_call_original
          allow(Rails.logger).to receive(:debug).with('Performing the work ... !')
          allow(Sidekiq.logger.instance_variable_get(:@logdev)).
            to receive(:write).
            with(
              %r{
                args=\["\[FILTERED:[ ]15[ ]bytes\]"\]
                #{memory_fields_before}
                \s+
                elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]done\n\z
              }x,
            ).
            and_call_original

          call

          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(
              %r{
                queue=default[ ]args=\["\[FILTERED:[ ]15[ ]bytes\]"\]
                #{memory_fields_before}:[ ]start\n\z
              }x,
            )
          expect(Rails.logger).to have_received(:debug).once.with('Performing the work ... !')
          expect(Sidekiq.logger.instance_variable_get(:@logdev)).
            to have_received(:write).once.
            with(
              %r{
                args=\["\[FILTERED:[ ]15[ ]bytes\]"\]
                #{memory_fields_before}
                \s+
                elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]done\n\z
              }x,
            )
        end
      end

      context 'when process memory information is unavailable' do
        let(:job_block) { proc {} }

        it 'logs an empty total when either memory value is missing' do
          allow(File).to receive(:foreach).and_call_original
          allow(File).to receive(:foreach).with('/proc/self/status').and_return(
            ["VmRSS:\t100 kB\n"].each,
          )
          logdev = Sidekiq.logger.instance_variable_get(:@logdev)
          allow(logdev).to receive(:write).and_call_original

          call

          expect(logdev).to have_received(:write).
            with(/process_memory_kib_before= heap_allocated_pages_before=\d+: start\n\z/)
          expect(logdev).to have_received(:write).
            with(/process_memory_kib_after= heap_allocated_pages_after=\d+/)
          expect(logdev).to have_received(:write).
            with(/process_memory_kib_delta= heap_allocated_pages_delta=-?\d+/)
        end

        it 'logs empty totals when the status file cannot be read' do
          allow(File).to receive(:foreach).and_call_original
          allow(File).to receive(:foreach).with('/proc/self/status').and_raise(Errno::ENOENT)
          logdev = Sidekiq.logger.instance_variable_get(:@logdev)
          allow(logdev).to receive(:write).and_call_original

          call

          expect(logdev).to have_received(:write).
            with(/process_memory_kib_before= heap_allocated_pages_before=\d+: start\n\z/)
          expect(logdev).to have_received(:write).
            with(/process_memory_kib_after= heap_allocated_pages_after=\d+/)
          expect(logdev).to have_received(:write).
            with(/process_memory_kib_delta= heap_allocated_pages_delta=-?\d+/)
        end
      end

      context 'when process memory information is available' do
        let(:job_block) { proc {} }

        it 'logs resident and swapped memory as a total' do
          allow(File).to receive(:foreach).and_call_original
          allow(File).to receive(:foreach).with('/proc/self/status').and_return(
            ["VmRSS:\t100 kB\n", "VmSwap:\t20 kB\n"].each,
            ["VmRSS:\t110 kB\n", "VmSwap:\t25 kB\n"].each,
          )
          logdev = Sidekiq.logger.instance_variable_get(:@logdev)
          allow(logdev).to receive(:write).and_call_original

          call

          expect(logdev).to have_received(:write).
            with(/process_memory_kib_before=120.*: start\n\z/)
          expect(logdev).to have_received(:write).
            with(/process_memory_kib_after=135/)
          expect(logdev).to have_received(:write).
            with(/process_memory_kib_delta=15/)
        end
      end
    end

    context 'when the executed job raises an error' do
      let(:job_block) { proc { raise('A problem occurred in the Sidekiq job!') } }

      it 'prints start job info, executes the block, and prints failed job info' do
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(/queue=default args=\["#{ip_address}"\]#{memory_fields_before}: start\n\z/).
          and_call_original
        allow(Sidekiq.logger.instance_variable_get(:@logdev)).
          to receive(:write).
          with(
            %r{
              queue=default[ ]args=\["#{ip_address}"\]
              #{memory_fields_before}
              \s+
              elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]fail\n\z
            }x,
          ).
          and_call_original

        expect { call }.to raise_error(/A problem occurred in the Sidekiq job!/)

        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(/queue=default args=\["#{ip_address}"\]#{memory_fields_before}: start\n\z/)
        expect(Sidekiq.logger.instance_variable_get(:@logdev)).
          to have_received(:write).once.
          with(
            %r{
              queue=default[ ]args=\["#{ip_address}"\]
              #{memory_fields_before}
              \s+
              elapsed=\d+\.\d{1,3}#{memory_fields_after}:[ ]fail\n\z
            }x,
          )
      end
    end
  end
end
