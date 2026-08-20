require 'net/http'

class Test::Tasks::StartPercy < Pallets::Task
  include Test::TaskHelpers

  PERCY_HEALTHCHECK_PATH = '/percy/healthcheck'
  PERCY_SERVER_PORT = 5338
  PERCY_STARTUP_TIMEOUT = 45

  def run
    if ENV['PERCY_TOKEN'].present?
      execute_detached_system_command('./node_modules/.bin/percy exec:start')

      # Avoid starting another Percy CLI process for each check. Loading the CLI can take
      # several seconds and compete with the Percy process that is still starting.
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      num_checks = 0
      sleep(6)

      loop do
        num_checks += 1

        if percy_running?
          record_success_and_log_message(<<~LOG.squish)
            Percy is running after #{num_checks} check(s)
            and #{elapsed_time(started_at)} seconds.
          LOG

          break
        elsif elapsed_time(started_at) >= PERCY_STARTUP_TIMEOUT
          record_failure_and_log_message(<<~LOG.squish)
            Percy is still not running after #{num_checks} attempt(s)
            and #{elapsed_time(started_at)} seconds.
          LOG

          break
        end

        sleep(0.1)
      end
    else
      record_success_and_log_message('Percy token was not present; skipping percy exec:start.')
    end
  end

  private

  def percy_running?
    response =
      Net::HTTP.start(
        '127.0.0.1',
        PERCY_SERVER_PORT,
        nil,
        open_timeout: 0.1,
        read_timeout: 0.1,
      ) do |http|
        http.get(PERCY_HEALTHCHECK_PATH)
      end

    response.is_a?(Net::HTTPSuccess)
  rescue SystemCallError, Timeout::Error
    false
  end

  def elapsed_time(started_at)
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at).round(3)
  end
end
