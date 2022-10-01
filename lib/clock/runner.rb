# frozen_string_literal: true

require 'erb'
require 'memoist'
require 'redlock'
require 'yaml'

class Clock::Runner
  extend Memoist

  # rubocop:disable Rails/TimeZone
  def run
    $stdout.sync = true
    puts("Clock is running with PID #{Process.pid}.")

    loop do
      execute_tasks
      sleep(seconds_until_next_minute(Time.now) + 0.001)
    end
  rescue SignalException
    # :nocov:
    puts('Thanks for using Clock! Exiting now.')
    exit(0) # rubocop:disable Rails/Exit
    # :nocov:
  end

  memoize \
  def lock_manager
    Redlock::Client.new(
      [Redis.new(url: RedisOptions.new.url)],
      { retry_count: 0 },
    )
  end

  private

  def execute_tasks
    tasks.each do |task|
      task.run if task.should_run?
    end
  end

  memoize \
  def tasks
    YAML.load(ERB.new(File.read('config/clock.yml')).result).map do |task_hash|
      Clock::Task.new(
        job_name: task_hash['job'],
        schedule_string: task_hash['schedule'],
        runner: self,
      )
    end
  end

  def seconds_until_next_minute(time)
    seconds_into_minute = Float(time.sec) + (Float(time) % 1.0)
    60.0 - seconds_into_minute
  end
  # rubocop:enable Rails/TimeZone
end
