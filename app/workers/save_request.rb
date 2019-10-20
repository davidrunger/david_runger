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

    saved_successfully = request.save
    if !saved_successfully
      warn_about_failure_to_save_request
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

  memoize \
  def final_stashed_json
    $redis.get("request_data:#{@request_uuid}:final")
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
    Rails.logger.warn(<<-LOG.squish)
      Stashed JSON for request logging was blank.
      initial_stashed_json=#{initial_stashed_json.inspect}
      request_uuid=#{@request_uuid.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Stashed JSON for request logging was blank'),
      initial_stashed_json: initial_stashed_json,
      request_uuid: @request_uuid,
    )
  end

  def warn_about_missing_final_stashed_json
    Rails.logger.warn(<<-LOG.squish)
      Stashed JSON for request logging was blank.
      final_stashed_json=#{final_stashed_json.inspect}
      request_uuid=#{@request_uuid.inspect}
    LOG
    Rollbar.warn(
      Request::CreateRequestError.new('Stashed JSON for request logging was blank'),
      final_stashed_json: final_stashed_json,
      request_uuid: @request_uuid,
    )
  end

  def warn_about_failure_to_save_request
    logger.error(<<-LOG.squish)
      Failed to create a Request,
      errors=#{request.errors.to_h},
      initial_stashed_json=#{initial_stashed_json.inspect},
      final_stashed_json=#{final_stashed_json.inspect},
      request_attributes=#{request_attributes.inspect}
    LOG
    Rollbar.error(
      Request::CreateRequestError.new('Failed to save a Request'),
      initial_stashed_json: initial_stashed_json,
      final_stashed_json: final_stashed_json,
      request_attributes: request_attributes,
      errors: request.errors.to_h,
    )
  end
end
