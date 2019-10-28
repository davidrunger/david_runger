# frozen_string_literal: true

module RequestRecordable
  class StashRequestError < StandardError; end

  extend ActiveSupport::Concern

  # The number of seconds to store request data in Redis (to later turn into a `Request`). Set to
  # 21.days because that's ~ how long Sidekiq (which processes this data) will attempt retries for.
  REQUEST_DATA_TTL = Integer(21.days)

  included do
    prepend_before_action :set_request_time
    before_action :store_initial_request_data_in_redis, if: :inherits_from_application_controller?
  end

  def store_initial_request_data_in_redis
    $redis_pool.with do |conn|
      conn.setex(
        initial_request_data_redis_key,
        REQUEST_DATA_TTL,
        request_data.to_json,
      )
    end
  rescue Encoding::UndefinedConversionError => error
    Rails.logger.info("Error storing request data in Redis, error=#{error.inspect}")
    Rollbar.info(error)
  rescue
    # wrap the original exception in StashRequestError by raising and immediately rescuing
    begin
      raise(StashRequestError, 'Failed to store request data in redis')
    rescue StashRequestError => error
      cause_error = error.cause
      Rails.logger.warn(<<-LOG.squish)
        Failed to store request data in redis,
        error=#{error.class}: #{error.message},
        cause=#{cause_error&.class}: #{cause_error&.message},
        request_data=#{request_data.inspect}
      LOG
      Rollbar.warning(error, request_data: request_data)
    end
  end

  private

  def inherits_from_application_controller?
    # We don't want to log requests to admin controllers or to pghero, for example.
    self.class.ancestors.include?(ApplicationController)
  end

  def initial_request_data_redis_key
    "request_data:#{request.request_id || fail('No request_id')}:initial"
  end

  def request_data
    @request_data ||= RequestDataBuilder.new(
      request: request,
      params: params,
      filtered_params: filtered_params,
      user: current_user,
      request_time: @request_time,
    ).request_data
  end

  def set_request_time
    @request_time = Time.current
  end
end
