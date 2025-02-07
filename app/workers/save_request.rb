# This Sidekiq worker class converts data that has been stashed in Redis at two stages in the
# request lifecycle into `Request` records saved to the Postgres database.
class SaveRequest
  prepend Memoization
  prepend ApplicationWorker

  unique_while_executing!

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

    return if Request.exists?(request_id: @request_id)

    if can_save_request?
      if ban_reasons.present?
        ban_requesting_ip
        delete_request_data
      else
        save_request
      end
    else
      log_unexpected_reasons_not_to_save_request
      delete_request_data
    end
  end

  private

  memoize \
  def ban_reasons
    ban_reasons = []

    if NullByteFinder.new(params).has_null_byte?
      ban_reasons << JSON(params)
    end

    ban_reasons
  end

  memoize \
  def params
    stashed_data['params']
  end

  def ban_requesting_ip
    CreateIpBlock.perform_async(stashed_data['ip'], ban_reasons.join("\n"))
  end

  def can_save_request?
    unexpected_reasons_not_to_save_request.blank?
  end

  def save_request
    request = Request.new(request_attributes)
    request.save!
  rescue => error
    handle_error_saving_request(error)
  else
    FetchIpInfoForRecord.perform_async(request.class.name, request.id)
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
      Rails.error.report(
        Error.new(Request::CreateRequestError, error_message),
        context: {
          initial_stashed_json:,
          final_stashed_json:,
          request_id: @request_id,
        },
      )
    end
  end

  def handle_error_saving_request(error)
    logger.warn("Failed to save Request; error=#{error} request_attributes=#{request_attributes}")
    # wrap the original exception in Request::CreateRequestError by re-raising
    raise(Request::CreateRequestError, 'Failed to save a Request')
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
      admin_user_id
      user_id
      auth_token_id
      view
      total
    ]).merge(
      request_id: @request_id,
      requested_at:,
    )
  end

  def requested_at
    Time.zone.at(stashed_data['requested_at_as_float'])
  end
end
