# frozen_string_literal: true

RSpec.describe ErrorLogger do
  subject(:error_logger) { ErrorLogger }

  describe '::warn' do
    subject(:warn) do
      ErrorLogger.warn(
        message: 'Something went wrong',
        error_klass: StandardError,
        data: {
          user_id: 123,
        },
      )
    end

    it 'calls Rails.logger.warn with the expected string' do
      expect(Rails.logger).to receive(:warn).
        with('StandardError: Something went wrong ; user_id=123').
        and_call_original

      warn
    end

    it 'calls Rollbar.warn with the expected arguments' do
      expect(Rollbar).to receive(:warn).with(StandardError, { user_id: 123 }).and_call_original

      warn
    end
  end
end
