# frozen_string_literal: true

RSpec.describe Clock::Task do
  subject(:task) do
    Clock::Task.new(
      job_name: 'InvalidRecordsCheck::Launcher',
      schedule_string: '23:59',
      runner: Clock::Runner.new,
    )
  end

  describe '#run' do
    subject(:run) { task.run }

    it 'sends a job hash to Redis', :frozen_time do
      expect {
        run
      }.to change {
        JSON(Sidekiq.redis { _1.call('lpop', 'queue:default') })
      }.from('null').to({
        'class' => 'InvalidRecordsCheck::Launcher',
        'queue' => 'default',
        'args' => [],
        'retry' => true,
        'jid' => /[0-9a-f]{24}/,
        'created_at' => Time.now.to_f,
        'enqueued_at' => Time.now.to_f,
      })
    end
  end
end
