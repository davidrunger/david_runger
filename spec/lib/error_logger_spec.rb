# frozen_string_literal: true

RSpec.describe ErrorLogger do
  let(:message) { 'Something went wrong' }
  let(:error_klass) { StandardError }

  describe '::warn' do
    context 'when data is provided' do
      subject(:warn) do
        ErrorLogger.warn(
          error_klass:,
          message:,
          data:,
        )
      end

      let(:data) { { user_id: 123 } }

      it 'calls Rails.logger.warn with the expected string' do
        expect(Rails.logger).to receive(:warn).
          with('StandardError: Something went wrong ; user_id=123').
          and_call_original

        warn
      end

      it 'calls Rollbar.warn with the expected arguments' do
        expect(Rollbar).to receive(:warn).and_wrap_original do |original, *args|
          expect(args.size).to eq(2)
          error, sent_data = args
          expect(error).to be_a(StandardError)
          expect(error.backtrace).not_to be_blank
          expect(error.message).to eq(message)
          expect(sent_data).to eq(data)

          original.call(*args)
        end

        warn
      end
    end

    context 'when data is not provided' do
      subject(:warn) do
        ErrorLogger.warn(
          error_klass:,
          message:,
        )
      end

      it 'calls Rails.logger.warn with the expected string' do
        expect(Rails.logger).to receive(:warn).
          with('StandardError: Something went wrong').
          and_call_original

        warn
      end

      it 'calls Rollbar.warn with the expected arguments' do
        expect(Rollbar).to receive(:warn).and_wrap_original do |original, *args|
          expect(args.size).to eq(1)
          error = args.first
          expect(error).to be_a(StandardError)
          expect(error.backtrace).not_to be_blank
          expect(error.message).to eq(message)

          original.call(*args)
        end

        warn
      end
    end
  end
end
