class ApplicationController < ActionController::Base
  class StashRequestError < StandardError ; end

  protect_from_forgery with: :exception
  before_action :store_request_data_in_redis
  before_action :authenticate_user!

  # not worth logging in `Request`s
  BORING_PARAMS = %w[controller action request_uuid format _method authenticity_token utf8]
  REQUEST_DATA_TTL = 60 # seconds to store data in Redis for later turning into a Request model

  private

  def authenticate_user!
    if !user_signed_in?
      flash[:alert] = 'You must sign in first.'
      session['user_redirect_to'] = request.path
      redirect_to login_path
    end
  end

  def bootstrap(data)
    @bootstrap_data ||= {}
    @bootstrap_data.merge!(data)
  end

  def after_sign_out_path_for(resource_or_scope)
    login_path
  end

  def store_request_data_in_redis
    current_user&.update!(last_activity_at: Time.current)
    browser = Browser.new(request.user_agent)
    request_data = {
      user_id: current_user&.id,
      url: request.url,
      method: request.request_method,
      handler: "#{params['controller']}##{params['action']}",
      params: filtered_params.except(*BORING_PARAMS),
      referer: request.referer,
      ip: request.ip,
      user_agent: <<-USER_AGENT.squish,
        #{browser.name}
        #{browser.version}
        #{browser.platform.name}
        mobile=#{browser.device.mobile? || false}
        raw=#{request.user_agent}
      USER_AGENT
      bot: (browser.bot? || false),
      requested_at: Time.current,
    }
    begin
      $redis.setex(params['request_uuid'], REQUEST_DATA_TTL, request_data.to_json)
    rescue => e
      # wrap the original exception in StashRequestError by raising and immediately rescuing
      begin
        raise StashRequestError.new('Failed to store request data in redis')
      rescue StashRequestError => e
        Rails.logger.warn(<<-LOG.squish)
          Failed to store request data in redis,
          error=#{e.class}: #{e.message},
          cause=#{e.cause&.class}: #{e.cause&.message},
          request_data=#{request_data.inspect}
        LOG
        Rollbar.warning($!, request_data: request_data)
      end
    end
  end

  def filtered_params
    filter = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
    filter.filter(params)
  end

  def render_json_error(message = 'There was a problem with your request', status = 400)
    render json: {error: message}, status: status
  end
end
