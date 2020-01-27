# frozen_string_literal: true

# This Sidekiq worker class converts data that has been stashed in Redis at two stages in the
# request lifecycle into `Request` records saved to the Postgres database.
class SaveRequest
  include Sidekiq::Worker

  delegate(
    :delete_request_data,
    :initial_stashed_json,
    :final_stashed_json,
    :stashed_data,
    to: :@stashed_data_manager,
  )

  def perform(request_id)
    @request_id = request_id
    @stashed_data_manager = SaveRequest::StashedDataManager.new(@request_id)

    if should_save_request?
      save_request
    else
      log_unexpected_reasons_not_to_save_request
      delete_request_data
    end
  end

  private

  def should_save_request?
    return false if DavidRunger::LogSkip.should_skip?(params: stashed_data['params'])

    unexpected_reasons_not_to_save_request.blank?
  end

  def save_request
    request = Request.new(request_attributes)
    request.save!
  rescue => error
    handle_error_saving_request(error)
  else
    FetchIpInfoForRequest.perform_async(request.id)
    delete_request_data
  end

  def unexpected_reasons_not_to_save_request
    [
      ('Initial stashed JSON for request logging was blank' if initial_stashed_json.blank?),
      ('Final stashed JSON for request logging was blank' if final_stashed_json.blank?),
    ].compact
  end

  def log_unexpected_reasons_not_to_save_request
    unexpected_reasons_not_to_save_request.each do |error_message|
      ErrorLogger.warn(
        message: error_message,
        error_klass: Request::CreateRequestError,
        data: {
          initial_stashed_json: initial_stashed_json,
          final_stashed_json: final_stashed_json,
          request_id: @request_id,
        },
      )
    end
  end

  def handle_error_saving_request(error)
    logger.warn("Failed to save Request; error=#{error} request_attributes=#{request_attributes}")
    # wrap the original exception in Request::CreateRequestError by re-raising
    raise(Request::CreateRequestError, 'Failed to store request data in redis')
  end

  def request_attributes
    stashed_data.slice(*%w[
      db
      format
      handler
      ip
      method
      params
      referer
      status
      url
      user_agent
      user_id
      view
    ]).merge(
      request_id: @request_id,
      requested_at: requested_at,
    )
  end

  def requested_at
    Time.zone.at(stashed_data['requested_at_as_float'])
  end
end
