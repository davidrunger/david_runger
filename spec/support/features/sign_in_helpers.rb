module Features::SignInHelpers
  def sign_in(resource, scope: nil)
    scope ||= Devise::Mapping.find_scope!(resource)

    Warden.on_next_request do |proxy|
      proxy.env['HTTP_USER_AGENT'] = 'Feature spec browser' if proxy.env['HTTP_USER_AGENT'].blank?
      proxy.env["authenticated_session.authentication_kind.#{scope}"] = 'legacy'
      proxy.set_user(resource, scope:, event: :authentication)
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
