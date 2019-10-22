# frozen_string_literal: true

class SaveRequest
  extend Memoist

  include Sidekiq::Worker
  include RequestRecordable::Helpers

  def perform(request_uuid)
    @request_uuid = request_uuid

    if initial_stashed_json.blank?
      warn_about_missing_initial_stashed_json
      return
    end

    if final_stashed_json.blank?
      warn_about_missing_final_stashed_json
      return
    end

    if DavidRunger::LogSkip.should_skip?(params: stashed_data['params'])
      return
    end

    begin
      request.save!
    rescue => error
      cause_error = error.cause
      logger.warn(<<~LOG.squish)
        Failed to store request data in redis.
        error_class=#{error.class}
        error_message=#{error.message}
        cause_error_class=#{cause_error&.class}
        cause_error_message=#{cause_error&.message}
        request_attributes=#{request_attributes.inspect}
      LOG

      # wrap the original exception in Request::CreateRequestError by re-raising
      raise(Request::CreateRequestError, 'Failed to store request data in redis')
    else
      # we no longer need the data, so delete it now (rather than waiting for REQUEST_DATA_TTL)
      $redis.del(
        initial_request_data_redis_key(request_uuid: @request_uuid),
        final_request_data_redis_key,
      )
    end
  end

  private

  memoize \
  def request
    Request.new(request_attributes)
  end

  memoize \
  def initial_stashed_json
    $redis.get(initial_request_data_redis_key(request_uuid: @request_uuid))
  end

  memoize \
  def stashed_data
    initial_stashed_data = JSON.parse(initial_stashed_json)
    final_stashed_data = JSON.parse(final_stashed_json)
    initial_stashed_data.merge(final_stashed_data)
  end

  def final_request_data_redis_key
    "request_data:#{@request_uuid}:final"
  end

  memoize \
  def final_stashed_json
    $redis.get(final_request_data_redis_key)
  end

  memoize \
  def request_attributes
    {
      user_id: stashed_data['user_id'],
      url: stashed_data['url'],
      format: stashed_data['format'],
      method: stashed_data['method'],
      status: stashed_data['status'],
      handler: stashed_data['handler'],
      params: stashed_data['params'],
      referer: stashed_data['referer'],
      view: stashed_data['view'],
      db: stashed_data['db'],
      ip: stashed_data['ip'],
      user_agent: stashed_data['user_agent'],
      requested_at: requested_at,
    }
  end

  memoize \
  def requested_at
    Time.zone.at(stashed_data['requested_at_as_float'])
  end

  def warn_about_missing_initial_stashed_json
    logger.warn(<<-LOG.squish)
      Initial stashed JSON for request logging was blank.
      initial_stashed_json=#{initial_stashed_json.inspect}
      request_uuid=#{@request_uuid.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Initial stashed JSON for request logging was blank'),
      initial_stashed_json: initial_stashed_json,
      request_uuid: @request_uuid,
    )
  end

  def warn_about_missing_final_stashed_json
    logger.warn(<<-LOG.squish)
      Final stashed JSON for request logging was blank.
      final_stashed_json=#{final_stashed_json.inspect}
      request_uuid=#{@request_uuid.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Final stashed JSON for request logging was blank'),
      final_stashed_json: final_stashed_json,
      request_uuid: @request_uuid,
    )
  end
end
