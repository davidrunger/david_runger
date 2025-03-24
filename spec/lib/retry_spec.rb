RSpec.describe Retry do
  # rubocop:disable RSpec/InstanceVariable
  describe '.retrying' do
    let(:logger) { instance_double(ActiveSupport::Logger) }

    before do
      allow(Retry).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
      @call_count = 0
    end

    context 'when the block succeeds on the first attempt' do
      let(:result) do
        Retry.retrying do
          success_message
        end
      end
      let(:success_message) { 'success' }

      it 'returns the result of the block and logs nothing' do
        expect(result).to eq(success_message)
        expect(logger).not_to have_received(:info)
      end
    end

    context 'when the block fails the first time but succeeds on retry' do
      let(:result) do
        Retry.retrying do
          @call_count += 1

          if @call_count == 1
            raise(StandardError, first_attempt_failure_message)
          else
            success_on_retry_message
          end
        end
      end
      let(:first_attempt_failure_message) { 'first attempt failed' }
      let(:success_on_retry_message) { 'success on retry' }

      it 'retries and returns the successful result' do
        expect(result).to eq(success_on_retry_message)
        expect(@call_count).to eq(2)
        expect(logger).to have_received(:info).
          with("Error: StandardError - #{first_attempt_failure_message}")
        expect(logger).to have_received(:info).with('Retrying...')
      end
    end

    context 'when the block fails on all attempts' do
      let(:result) do
        Retry.retrying do
          @call_count += 1
          raise(StandardError, "Attempt #{@call_count} failed")
        end
      end

      it 'retries twice (three tries total) and re-raises the last error' do
        expect { result }.to raise_error(StandardError, 'Attempt 3 failed')
        expect(@call_count).to eq(3)
        expect(logger).to have_received(:info).with('Error: StandardError - Attempt 1 failed')
        expect(logger).to have_received(:info).with('Error: StandardError - Attempt 2 failed')
        expect(logger).to have_received(:info).with('Error: StandardError - Attempt 3 failed')
        expect(logger).to have_received(:info).with('Retrying...').twice
        expect(logger).to have_received(:info).with('Retries exhausted; raising.')
      end
    end

    context 'when specifying an :errors option' do
      context 'when an error of a class listed in :errors is raised' do
        let(:result) do
          Retry.retrying(times: 1, errors: [ArgumentError]) do
            @call_count += 1
            raise(ArgumentError, handled_error_message)
          end
        end
        let(:handled_error_message) { 'This error type is handled' }

        it 'retries' do
          expect { result }.to raise_error(ArgumentError, handled_error_message)
          expect(@call_count).to eq(2) # Original + 1 retry
        end
      end

      context 'when an error of a class not listed in :errors is raised' do
        let(:result) do
          Retry.retrying(errors: [ArgumentError]) do
            @call_count += 1
            raise(not_handled_error_message)
          end
        end
        let(:not_handled_error_message) { 'This error type is not handled' }

        it 'does not retry' do
          expect { result }.to raise_error(RuntimeError, not_handled_error_message)
          expect(@call_count).to eq(1) # No retries
        end
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable

  describe '.logger' do
    it 'returns a tagged logger' do
      expect(Retry.logger).to be_a(ActiveSupport::TaggedLogging)
    end

    it 'uses MemoWise to cache the logger' do
      first_logger = Retry.logger
      second_logger = Retry.logger

      expect(first_logger).to be(second_logger)
    end
  end
end
