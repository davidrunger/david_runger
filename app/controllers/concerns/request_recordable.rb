module RequestRecordable
  class StashRequestError < StandardError; end

  extend ActiveSupport::Concern

  REQUEST_DATA_TTL = 60 # seconds to store data in Redis for later turning into a Request model

  included do
    before_action :update_user_last_activity_at, if: -> { current_user.present? }
    before_action :store_request_data_in_redis
  end

  def update_user_last_activity_at
    current_user.update!(last_activity_at: request_time)
  end

  def store_request_data_in_redis
    $redis.setex(params['request_uuid'], REQUEST_DATA_TTL, request_data.to_json)
  rescue Encoding::UndefinedConversionError => error
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

  def request_data
    @request_data ||= RequestDataBuilder.new(
      request: request,
      params: params,
      filtered_params: filtered_params,
      user: current_user,
      request_time: request_time,
    ).request_data
  end

  def request_time
    @request_time ||= Time.current
  end
end
