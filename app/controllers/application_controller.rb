class ApplicationController < ActionController::Base
  include Bootstrappable
  include BrowserSupportCheckable
  include Classable
  include Pundit::Authorization
  include RequestRecordable
  include SchemaValidatable
  include TokenAuthenticatable

  AUTHORIZATION_ERROR_MESSAGES = {
    Pundit::NotAuthorizedError => 'You are not authorized to perform this action.',
    TokenAuthenticatable::InvalidToken => 'Your token is not valid.',
  }.freeze

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :prioritize_json_format
  before_action :set_paper_trail_whodunnit
  before_action :set_browser_uuid
  before_action :set_controller_action_in_context
  before_action :store_redirect_chain

  after_action :verify_authorized, unless: :skip_authorization?

  rescue_from(*AUTHORIZATION_ERROR_MESSAGES.keys, with: :user_not_authorized)

  def self.require_admin_user!
    skip_before_action(:authenticate_user!)
    before_action(:authenticate_admin_user!)

    class_eval do
      private

      def pundit_user
        current_admin_user
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

  def set_controller_action_in_context
    ActiveSupport::ExecutionContext[:controller_action] =
      ActiveSupport::ExecutionContext.to_h[:controller_action] ||
      "#{params['controller']}##{params['action']}"
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

  # rubocop:disable Metrics/PerceivedComplexity
  def prioritize_json_format
    if request.accepts.any?
      # Parse accept header directly since Mime::Type doesn't expose parameters
      accepts = request.headers['Accept'].to_s.split(',').map do |accept|
        type, params = accept.strip.split(';')
        # rubocop:disable Lint/NumberConversion
        q = params&.match(/q=([0-9.]+)/)&.[](1)&.to_f || 1.0
        # rubocop:enable Lint/NumberConversion
        [type, q]
      end.sort_by { |_, q| -q } # Sort by q value descending

      # If application/json has highest priority (tied or better),
      # force request format to JSON
      json_priority = accepts.find { |type, _| type == 'application/json' }&.last || 0
      highest_priority = accepts.first&.last || 0

      if json_priority >= highest_priority && json_priority > 0
        request.format = :json
      end
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  def redirect_location
    next_redirect_chain_value ||
      session.delete('user_return_to') ||
      root_path
  end

  def store_redirect_chain
    if (redirect_chain =
      params[:redirect_chain] ||
      request.env['omniauth.origin'].presence
    ) && redirect_chain != new_user_session_url
      session[:redirect_chain] = redirect_chain
    end
  end

  def next_redirect_chain_value
    if (redirect_chain = session.delete(:redirect_chain)&.split('|'))
      next_value = first_redirect_chain_value_to_follow(redirect_chain)

      if redirect_chain.present?
        session[:redirect_chain] = redirect_chain.join('|')
      end

      next_value
    end
  end

  def first_redirect_chain_value_to_follow(redirect_chain)
    20.times do
      next_value = redirect_chain.shift

      if next_value.start_with?('wizard:')
        wizard_type = next_value.delete_prefix('wizard:')

        if wizard_type == 'set-public-name-if-new' && current_user.created_at > 1.minute.ago
          return edit_public_name_my_account_path
        end
      else
        return next_value
      end
    end

    nil
  end
end
