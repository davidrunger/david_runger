# frozen_string_literal: true

class SaveRequest
  extend Memoist

  include Sidekiq::Worker

  def perform(request_id)
    @request_id = request_id

    if initial_stashed_json.blank?
      delete_request_data # delete the final stashed data, if it's there
      warn_about_missing_initial_stashed_json
      return
    end

    if final_stashed_json.blank?
      delete_request_data # delete the initial stashed data, if it's there
      warn_about_missing_final_stashed_json
      return
    end

    if DavidRunger::LogSkip.should_skip?(params: stashed_data['params'])
      delete_request_data
      return
    end

    begin
      request.save!
      FetchIpInfoForRequest.perform_async(request.id)
    rescue => error
      logger.warn(<<~LOG.squish)
        Failed to store request data in redis.
        error_class=#{error.class}
        error_message=#{error.message}
        request_attributes=#{request_attributes.inspect}
      LOG

      # wrap the original exception in Request::CreateRequestError by re-raising
      raise(Request::CreateRequestError, 'Failed to store request data in redis')
    else
      # we no longer need the data, so delete it now (rather than waiting for REQUEST_DATA_TTL)
      delete_request_data
    end
  end

  private

  def delete_request_data
    $redis_pool.with do |conn|
      conn.del(
        initial_request_data_redis_key,
        final_request_data_redis_key,
      )
    end
  end

  memoize \
  def request
    Request.new(request_attributes)
  end

  memoize \
  def initial_request_data_redis_key
    "request_data:#{@request_id}:initial"
  end

  memoize \
  def initial_stashed_json
    $redis_pool.with { |conn| conn.get(initial_request_data_redis_key) }
  end

  memoize \
  def stashed_data
    initial_stashed_data = JSON.parse(initial_stashed_json)
    final_stashed_data = JSON.parse(final_stashed_json)
    initial_stashed_data.merge(final_stashed_data)
  end

  memoize \
  def final_request_data_redis_key
    "request_data:#{@request_id}:final"
  end

  memoize \
  def final_stashed_json
    $redis_pool.with { |conn| conn.get(final_request_data_redis_key) }
  end

  memoize \
  def request_attributes
    {
      request_id: @request_id,
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
      request_id=#{@request_id.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Initial stashed JSON for request logging was blank'),
      initial_stashed_json: initial_stashed_json,
      request_id: @request_id,
    )
  end

  def warn_about_missing_final_stashed_json
    logger.warn(<<-LOG.squish)
      Final stashed JSON for request logging was blank.
      final_stashed_json=#{final_stashed_json.inspect}
      request_id=#{@request_id.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Final stashed JSON for request logging was blank'),
      final_stashed_json: final_stashed_json,
      request_id: @request_id,
    )
  end
end
