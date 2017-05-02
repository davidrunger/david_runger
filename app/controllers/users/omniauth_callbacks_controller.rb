class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!, only: [:google_oauth2]

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    user = User.from_omniauth!(request.env["omniauth.auth"])
    sign_in user
    redirect_to templates_path
  end
end
