require 'net/http'

module Features::PercyHelpers
  PERCY_HEALTHCHECK_PATH = '/percy/healthcheck'
  PERCY_SERVER_PORT = 5338
  PERCY_WAIT_TIMEOUT = 45

  def take_percy_snapshot(snapshot_name)
    wait_for_percy(snapshot_name) if ENV['PERCY_TOKEN'].present?

    page.percy_snapshot(snapshot_name)
  end

  private

  def wait_for_percy(snapshot_name)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    with_wait(timeout: PERCY_WAIT_TIMEOUT) do
      wait_for { percy_running? }.to be(true), 'Percy did not start before the snapshot'
    end

    elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    RSpec.configuration.reporter.message(<<~LOG.squish)
      Waited #{elapsed_time.round(3)} seconds for Percy before taking the
      "#{snapshot_name}" snapshot.
    LOG
  end

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
end
