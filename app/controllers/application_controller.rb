# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Bootstrappable
  include BrowserSupportCheckable
  include ContainerClassable
  include Pundit::Authorization
  include RequestRecordable
  include TokenAuthenticatable

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit

  after_action :verify_authorized, unless: :skip_authorization?

  rescue_from(
    Pundit::NotAuthorizedError,
    TokenAuthenticatable::BlankToken,
    TokenAuthenticatable::InvalidToken,
    with: :user_not_authorized,
  )

  def current_user
    if Rails.env.development? && Flipper.enabled?(:automatic_user_login)
      super || User.find_by!(email: 'davidjrunger@gmail.com').tap { |user| sign_in(user) }
    else
      super
    end
  end

  def current_admin_user
    if Rails.env.development? && Flipper.enabled?(:automatic_admin_login)
      super ||
        AdminUser.
          find_by!(email: 'davidjrunger@gmail.com').
          tap { |admin_user| sign_in(admin_user) }
    else
      super
    end
  end

  private

  def skip_authorization?
    controller = params[:controller]

    # ActiveAdmin supports an "Authorization Adapter" that can be implemented separately; skip here.
    return true if controller.match?(%r{\Aactive_admin/|admin/})

    # All users are allowed to sign out; we don't need to check a pundit policy.
    # We can't add `skip_authorization` to the controller because the controller is in `devise`.
    controller == 'devise/sessions' && params[:action] == 'destroy'
  end

  # add additional data here for inclusion in logs
  def append_info_to_payload(payload)
    super(payload)
    payload[:ip] = request.remote_ip
    payload[:admin_user_id] = current_admin_user.id if current_admin_user.present?
    payload[:user_id] = current_user.id if current_user.present?
  end

  def authenticate_user!
    return if skip_authorization? || user_signed_in? || auth_token_user.present?

    if request.format.json?
      render_json_error('Your request was not authenticated', 401)
    else
      flash[:alert] = 'You must sign in first.'
      session['user_return_to'] = request.path
      redirect_to(login_path)
    end
  end

  def authenticate_admin_user!
    return if admin_user_signed_in?

    flash[:alert] = 'You must sign in as an admin user first.'
    session['admin_user_return_to'] = request.path
    redirect_to(admin_login_path)
  end

  # override Rails's built-in #verify_authenticity_token method to allow for `auth_token` use
  def verify_authenticity_token
    if auth_token_param.present?
      verify_valid_auth_token!
    else
      super
    end
  end

  def render_json_error(message = 'There was a problem with your request', status = 400)
    render json: { error: message }, status:
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
