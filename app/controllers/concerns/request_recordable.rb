module RequestRecordable
  extend ActiveSupport::Concern
  prepend Memoization

  # The number of seconds to store request data in Redis (to later turn into a `Request`). Set to
  # 21.days because that's ~ how long Sidekiq (which processes this data) will attempt retries for.
  REQUEST_DATA_TTL = Integer(21.days)

  included do
    prepend_before_action :set_request_time
    before_action :store_initial_request_data_in_redis
  end

  private

  def store_initial_request_data_in_redis
    unless SaveRequest::SkipChecker.new(params: params.to_unsafe_h).skip?
      $redis_pool.with do |conn|
        conn.call('setex', initial_request_data_redis_key, REQUEST_DATA_TTL, request_data.to_json)
      end
    end
  rescue JSON::GeneratorError
    Rails.logger.info("[RequestRecordable][JSON::GeneratorError] #{request_data.inspect}")
    raise
  end

  def initial_request_data_redis_key
    "request_data:#{request.request_id.presence!('No request_id')}:initial"
  end

  memoize \
  def request_data
    SaveRequest::RequestDataBuilder.new(
      request:,
      params:,
      filtered_params:,
      admin_user: current_admin_user,
      user: current_user,
      auth_token:,
      request_time: @request_time,
    ).request_data
  end

  def set_request_time
    @request_time = Time.current
  end

  def filtered_params
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filter.filter(params)
  end
end
