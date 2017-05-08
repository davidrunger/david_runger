class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def authenticate_user!
    if !user_signed_in?
      flash[:alert] = 'You must sign in first.'
      session['user_redirect_to'] = request.path
      redirect_to login_path
    end
  end

  def bootstrap(data)
  	@bootstrap_data ||= {}
  	@bootstrap_data.merge!(data)
  end

  def after_sign_out_path_for(resource_or_scope)
    login_path
  end
end
