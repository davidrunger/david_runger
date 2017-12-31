class ApplicationController < ActionController::Base
  include Pundit
  include RequestRecordable

  protect_from_forgery with: :exception

  before_action :count_request
  before_action :authenticate_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # add user_id to event payload so that we can include it in logs
  def append_info_to_payload(payload)
    super(payload)
    payload[:user_id] = current_user.id if current_user.present?
  end

  def authenticate_user
    return if user_signed_in?

    flash[:alert] = 'You must sign in first.'
    session['user_redirect_to'] = request.path
    redirect_to(login_path)
  end

  def bootstrap(data)
    @bootstrap_data ||= {}
    @bootstrap_data.merge!(data)
  end

  def after_sign_out_path_for(_resource_or_scope)
    login_path
  end

  def count_request
    StatsD.increment('requests')
  end

  def filtered_params
    filter = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
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
