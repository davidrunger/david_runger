class ApplicationController < ActionController::Base
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
        bot=#{browser.bot? || false}
        raw=#{request.user_agent}
      USER_AGENT
      requested_at: Time.current,
    }
    $redis.setex(params['request_uuid'], REQUEST_DATA_TTL, request_data.to_json)
  end

  def filtered_params
    filter = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
    filter.filter(params)
  end
end
