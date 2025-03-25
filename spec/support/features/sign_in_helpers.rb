module Features::SignInHelpers
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
