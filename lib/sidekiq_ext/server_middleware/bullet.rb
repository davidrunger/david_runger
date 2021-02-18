# frozen_string_literal: true

module SidekiqExt::ServerMiddleware ; end

class SidekiqExt::ServerMiddleware::Bullet
  def call(_worker, _job, _queue)
    # rubocop:disable Style/ExplicitBlockArgument
    Bullet.profile do
      yield
    end
    # rubocop:enable Style/ExplicitBlockArgument
  end
end
