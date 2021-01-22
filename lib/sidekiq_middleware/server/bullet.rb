# frozen_string_literal: true

module SidekiqMiddleware; end
module SidekiqMiddleware::Server; end

class SidekiqMiddleware::Server::Bullet
  def call(_worker, _job, _queue)
    # rubocop:disable Style/ExplicitBlockArgument
    Bullet.profile do
      yield
    end
    # rubocop:enable Style/ExplicitBlockArgument
  end
end
