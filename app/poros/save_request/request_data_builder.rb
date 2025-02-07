class SaveRequest::RequestDataBuilder
  prepend Memoization

  # params not worth logging in `Request`s
  BORING_PARAMS = %w[
    _method
    action
    authenticity_token
    controller
    format
    utf8
  ].map(&:freeze).freeze

  # rubocop:disable Metrics/ParameterLists
  def initialize(
    request:,
    params:,
    filtered_params:,
    admin_user:,
    user:,
    auth_token:,
    request_time:
  )
    # rubocop:enable Metrics/ParameterLists
    @request = request
    @params = params
    @filtered_params = filtered_params
    @admin_user = admin_user
    @user = user
    @auth_token = auth_token
    @request_time = request_time
  end

  memoize \
  def request_data
    @request_data = {
      admin_user_id: @admin_user&.id,
      user_id: @user&.id,
      auth_token_id: @auth_token&.id,
      url: @request.url,
      method: @request.request_method,
      handler: "#{@params['controller']}##{@params['action']}",
      params: @filtered_params.except(*BORING_PARAMS),
      referer: @request.referer,
      ip: @request.remote_ip,
      user_agent: raw_user_agent,
      requested_at_as_float: Float(@request_time),
      format: @request.format.symbol,
    }
  end

  private

  memoize \
  def raw_user_agent
    @request.user_agent&.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end
