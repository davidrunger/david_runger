# frozen_string_literal: true

class RequestDataBuilder
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
  def initialize(request:, params:, filtered_params:, user:, auth_token:, request_time:)
    # rubocop:enable Metrics/ParameterLists
    @request = request
    @params = params
    @filtered_params = filtered_params
    @user = user
    @auth_token = auth_token
    @request_time = request_time
  end

  def request_data
    return @request_data if defined?(@request_data)

    @request_data = {
      user_id: @user&.id,
      auth_token_id: @auth_token&.id,
      url: @request.url,
      method: @request.request_method,
      handler: "#{@params['controller']}##{@params['action']}",
      params: @filtered_params.except(*BORING_PARAMS),
      referer: @request.referer,
      ip: @request.ip,
      user_agent: raw_user_agent,
      requested_at_as_float: Float(@request_time),
      format: @request.format.symbol,
    }
  end

  private

  def raw_user_agent
    @raw_user_agent ||= @request.user_agent
  end
end
