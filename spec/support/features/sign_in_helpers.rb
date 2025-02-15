module Features::SignInHelpers
  def sign_in_confirmed_via_my_account?(user)
    visit(my_account_path)

    Capybara.using_wait_time(0.1) do
      page.has_text?(user.email)
    end
  end
end
