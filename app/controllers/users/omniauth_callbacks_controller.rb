class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    user = User.from_omniauth!(request.env["omniauth.auth"])
    sign_in user
    redirect_to root_path
  end
end
