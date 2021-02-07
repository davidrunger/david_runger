# frozen_string_literal: true

RSpec.describe DataMonitors::HomeIndexRequests do
  subject(:worker) { DataMonitors::HomeIndexRequests.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    it 'verifies some data expectations' do
      expect(worker).to receive(:verify_data_expectation).at_least(:twice).and_call_original
      perform
    end

    context 'when the `number_of_requests_in_past_day expectation` fails' do
      before { Request.find_each(&:destroy) }

      let(:full_check_name) { 'DataMonitors::HomeIndexRequests#number_of_requests_in_past_day' }

      context 'when no email has been sent within the past 24 hours' do
        it 'enqueues an email', :frozen_time, queue_adapter: :test do
          expect { perform }.
            to enqueue_mail(DataMonitorMailer, :expectation_not_met).
            with(args: [
              full_check_name,
              0,
              String,
              Time.current.to_s,
            ])
        end
      end

      context 'when an email has been sent within the past 24 hours' do
        before { DataMonitors::HomeIndexRequests.new.perform }

        it 'does not enqueue an email', :frozen_time, queue_adapter: :test do
          expect { perform }.
            not_to enqueue_mail(DataMonitorMailer, :expectation_not_met).
            with(args: [full_check_name, anything, anything, anything])
        end
      end
    end
  end
end
