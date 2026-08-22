module Features::SignInHelpers
  SIGN_IN_TOKEN_HEADER = 'X-Capybara-Sign-In-Token'
  SIGN_IN_TOKEN_ENV_KEY = 'HTTP_X_CAPYBARA_SIGN_IN_TOKEN'

  class << self
    def register_sign_in(resource:, scope:)
      SecureRandom.uuid.tap do |token|
        pending_sign_ins_mutex.synchronize do
          pending_sign_ins[token] = { resource:, scope: }
        end
      end
    end

    def consume_sign_in(token)
      if token
        pending_sign_ins_mutex.synchronize { pending_sign_ins.delete(token) }
      end
    end

    def reset!
      pending_sign_ins_mutex.synchronize { pending_sign_ins.clear }
    end

    private

    def pending_sign_ins
      @pending_sign_ins ||= {}
    end

    def pending_sign_ins_mutex
      @pending_sign_ins_mutex ||= Mutex.new
    end
  end

  def sign_in(resource, scope: nil)
    scope ||= Devise::Mapping.find_scope!(resource)
    token = Features::SignInHelpers.register_sign_in(resource:, scope:)

    if page.driver.respond_to?(:add_header)
      page.driver.add_header(SIGN_IN_TOKEN_HEADER, token)
    else
      page.driver.header(SIGN_IN_TOKEN_HEADER, token)
    end
  end

  def click_sign_in_with_google
    within(find('google-sign-in-button').shadow_root) do
      find('button', text: 'Sign in with Google').trigger('click')
    end
  end

  def sign_in_confirmed_via_my_account?(user)
    visit(my_account_path)

    Capybara.using_wait_time(0.1) do
      page.has_text?(user.email)
    end
  end
end

# `Warden.on_next_request` is process-global, so an Action Cable request from a different
# Capybara session can consume a pending sign-in. Match the sign-in to a per-session header.
Warden::Manager.on_request do |proxy|
  sign_in = Features::SignInHelpers.consume_sign_in(
    proxy.env[Features::SignInHelpers::SIGN_IN_TOKEN_ENV_KEY],
  )
  unless sign_in
    next
  end

  resource, scope = sign_in.values_at(:resource, :scope)
  if proxy.env['HTTP_USER_AGENT'].blank?
    proxy.env['HTTP_USER_AGENT'] = 'Feature spec browser'
  end
  proxy.env["authenticated_session.authentication_kind.#{scope}"] = 'legacy'
  proxy.set_user(resource, scope:, event: :authentication)
end

RSpec.configure do |config|
  config.after(:each, type: :feature) { Features::SignInHelpers.reset! }
end
