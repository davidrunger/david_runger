RSpec.describe ErrorSubscriber do
  subject(:error_subscriber) { ErrorSubscriber.new }

  describe '#report' do
    subject(:report) do
      error_subscriber.report(
        error,
        handled:,
        severity:,
        context:,
      )
    end

    let(:error) { error_class.new }
    let(:error_class) { StandardError }
    let(:handled) { true }
    let(:severity) { :warning }
    let(:context) { {} }

    context 'when the severity is :error' do
      let(:severity) { :error }

      context 'when the error is not handled' do
        let(:handled) { false }

        context 'when the error class is Sidekiq::JobRetry::Skip' do
          let(:error_class) do
            require 'sidekiq/job_retry'

            Sidekiq::JobRetry::Skip
          end

          context 'when the error has another cause error' do
            let(:first_error_message) { 'First error' }
            let(:error) do
              begin
                raise(StandardError, first_error_message)
              rescue
                raise(error_class, 'Second error')
              end
            rescue => error
              error
            end

            it 'writes a log line using the cause error' do
              allow(Rails.logger).
                to receive(:error).
                with(/#{first_error_message}/).
                and_call_original

              report

              expect(Rails.logger).
                to have_received(:error).once.
                with(/#{first_error_message}/)
            end

            it 'does not send anything to Rollbar' do
              allow(Rollbar).to receive(:log)
              allow(Rollbar).to receive(:error)

              report

              expect(Rollbar).not_to have_received(:log)
              expect(Rollbar).not_to have_received(:error)
            end
          end
        end

        context 'when the error class is StandardError' do
          let(:error_class) { StandardError }

          it 'sends the error to Rollbar' do
            allow(Rollbar).
              to receive(:log).with(
                :error,
                an_instance_of(StandardError),
                { handled: false },
              )

            report

            expect(Rollbar).to have_received(:log).once.with(
              :error,
              an_instance_of(StandardError),
              { handled: false },
            ).once
          end
        end
      end
    end
  end
end
