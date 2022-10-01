# frozen_string_literal: true

RSpec.describe Clock::Runner do
  subject(:runner) { Clock::Runner.new }

  describe '#run' do
    subject(:run) { runner.run }

    before do
      expect(runner).to receive(:loop) do |&block|
        expect { block.call }.not_to raise_error
      end
    end

    let(:email_reminders_task) do
      # this task is scheduled to run every minute, so it should run regardless of the time
      runner.
        __send__(:tasks).
        detect { _1.instance_variable_get(:@job_name) == 'SendLogReminderEmails' }
    end

    it 'runs the tasks that should be run' do
      expect(email_reminders_task).to receive(:run).and_call_original

      # Travel to near the end of a minute (59 seconds) because the #run block will `sleep` until
      # the beginning of the next minute.
      travel_to Time.zone.local(2022, 9, 30, 23, 34, 59) do
        run
      end
    end
  end
end
