class Admin::SessionsController < Sessions::BaseController
  skip_before_action :authenticate_user!, only: [:new]

  def new
    skip_authorization
    if admin_user_signed_in?
      flash[:notice] = 'You are already logged in.'
      redirect_to(admin_root_path)
    else
      @title = 'Admin login'
      render :new
    end
  end
end
