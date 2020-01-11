# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  include RequestRecordable

  protect_from_forgery with: :exception

  before_action :count_request, unless: -> { DavidRunger::LogSkip.should_skip?(params: params) }
  before_action :authenticate_user
  before_action :store_redirect_location
  before_action :enqueue_touch_activity_at_worker, if: -> { current_user.present? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def enqueue_touch_activity_at_worker
    TouchActivityAt.perform_async(current_user.id, Float(@request_time))
  end

  # add additional data here for inclusion in logs
  def append_info_to_payload(payload)
    super(payload)
    payload[:ip] = request.remote_ip
    payload[:user_id] = current_user.id if current_user.present?
  end

  def authenticate_user
    return if user_signed_in?

    flash[:alert] = 'You must sign in first.'
    session['user_return_to'] = request.path
    redirect_to(login_path)
  end

  def store_redirect_location
    if params['redirect_to'].present?
      session['redirect_to'] = params['redirect_to']
    end
  end

  def bootstrap(data)
    @bootstrap_data ||= {}
    @bootstrap_data.merge!(data)
  end

  def after_sign_out_path_for(_resource_or_scope)
    login_path
  end

  def count_request
    StatsD.increment("requests_by_action.#{params['controller']}-#{params['action']}")
    StatsD.increment("requests_by_user.#{current_user&.id || 0}")
  end

  def filtered_params
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filter.filter(params)
  end

  def render_json_error(message = 'There was a problem with your request', status = 400)
    render json: {error: message}, status: status
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    respond_to do |format|
      format.html { redirect_to(request.referer || root_path) }
      format.json { render_json_error('You are not authorized.', 403) }
    end
  end
end
