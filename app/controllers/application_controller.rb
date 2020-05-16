# frozen_string_literal: true

# Per Rails convention, this is the base class from which (almost?) all of our controllers inherit.
# We are getting some ignorable warnings about :reek:InstanceVariableAssumption
class ApplicationController < ActionController::Base
  include ActivityTrackable
  include Bootstrappable
  include Pundit
  include Redirectable
  include RequestRecordable

  protect_from_forgery with: :exception

  before_action :authenticate_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

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

  def after_sign_out_path_for(_resource_or_scope)
    login_path
  end

  def filtered_params
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filter.filter(params)
  end

  def render_json_error(message = 'There was a problem with your request', status = 400)
    render json: {error: message}, status: status
  end

  def user_not_authorized
    respond_to do |format|
      format.html do
        flash[:alert] = 'You are not authorized to perform this action.'
        redirect_to(request.referer || root_path)
      end
      format.json do
        render_json_error('You are not authorized.', 403)
      end
    end
  end
end
