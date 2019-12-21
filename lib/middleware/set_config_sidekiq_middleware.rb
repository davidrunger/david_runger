# frozen_string_literal: true

class Middleware::SetConfigSidekiqMiddleware
  def call(_worker, _job_hash, _queue)
    Runger.config.memoize_settings_from_redis
    # rubocop:disable Lint/Debugger, Layout/LineLength
    binding.pry if Runger.config.pause_sidekiq? && (!$stop_skipping_at || (Time.current >= $stop_skipping_at))
    # rubocop:enable Lint/Debugger, Layout/LineLength
    yield
  end
end
