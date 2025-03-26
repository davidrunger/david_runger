class HealthChecksController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :skip_authorization, only: :index

  def index
    [
      Thread.new { check_postgres },
      Thread.new { check_redis },
    ].each(&:join)

    head :ok
  end

  private

  def check_postgres
    reraising_in_main_thread do
      ActiveRecord::Base.logger.silence do
        User.select(:id).first.id
      end
    end
  end

  def check_redis
    reraising_in_main_thread do
      $redis_pool.with { it.call('ping') }
    end
  end

  # NOTE: This method avoids a warning about a thread being terminated with an exception.
  def reraising_in_main_thread
    yield
  rescue => error
    Thread.main.raise(error)
  end
end
