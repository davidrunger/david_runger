class ApplicationController < ActionController::Base
  include Bootstrappable
  include BrowserSupportCheckable
  include Classable
  include JsonPrioritizable
  include JsToastable
  include Pundit::Authorization
  include Redirectable
  include RequestRecordable
  include SchemaValidatable
  include TokenAuthenticatable
  prepend Memoization

  AUTHORIZATION_ERROR_MESSAGES = {
    Pundit::NotAuthorizedError => 'You are not authorized to perform this action.',
    TokenAuthenticatable::InvalidToken =>
      ->(_controller) { "Your token is not valid for #{controller_action}." },
  }.freeze

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_browser_uuid
  before_action :set_controller_action_in_context

  after_action :verify_authorized, unless: :skip_authorization?

  rescue_from(*AUTHORIZATION_ERROR_MESSAGES.keys, with: :user_not_authorized)

  class << self
    def allow_auth_token_authorization
      class_eval do
        def pundit_user
          current_or_auth_token_user
        end
      end
    end

    def require_admin_user!
      skip_before_action(:authenticate_user!)
      before_action(:authenticate_admin_user!)

      class_eval do
        private

        def pundit_user
          current_admin_user
        end
      end
    end
  end

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

  memoize \
  def controller_action
    ActiveSupport::ExecutionContext.to_h[:controller_action] ||
      "#{params['controller']}##{params['action']}"
  end

  def set_controller_action_in_context
    ActiveSupport::ExecutionContext[:controller_action] = controller_action
  end

  def set_browser_uuid
    # NOTE: This cookie cannot be HTTP-only because we read it in JavaScript code.
    cookies[:browser_uuid] ||= SecureRandom.uuid
    Current.browser_uuid = cookies[:browser_uuid]
  end

  def _render_with_renderer_json(resource, options)
    super(resource_for_json_rendering(resource), options)
  end

  def resource_for_json_rendering(resource)
    if resource.is_a?(ApplicationRecord)
      resource.serializer(current_user:)
    else
      resource
    end
  end

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
    super
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
      redirect_to(new_user_session_path)
    end
  end

  def authenticate_admin_user!
    return if admin_user_signed_in?

    flash[:alert] = 'You must sign in as an admin user first.'
    session['admin_user_return_to'] = request.path
    # NOTE: Specify `main_app` for path because this method is also used by Blazer.
    redirect_to(main_app.new_admin_user_session_path)
  end

  # override Rails's built-in #verify_authenticity_token method to allow for `auth_token` use
  def verify_authenticity_token
    if auth_token_secret.present?
      verify_valid_auth_token!
    else
      super
    end
  end

  def render_json_error(message = 'There was a problem with your request', status = 400)
    render json: { error: message }, status:
  end

  def user_not_authorized(exception)
    message = AUTHORIZATION_ERROR_MESSAGES.fetch(
      exception.class,
      'You are not authorized.',
    )

    if message.respond_to?(:call)
      message = instance_eval(&message)
    end

    respond_to do |format|
      format.html do
        flash[:alert] = message
        redirect_to(request.referer || root_path)
      end
      format.json do
        render_json_error(message, 403)
      end
    end
  end
end
