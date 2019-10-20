# frozen_string_literal: true

# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
class Admin::ApplicationController < Administrate::ApplicationController
  before_action :authenticate_admin

  def authenticate_admin
    return if current_user&.admin?

    if current_user
      redirect_to(root_path)
    else
      flash[:alert] = 'You must sign in first.'
      session['user_return_to'] = request.path
      redirect_to(login_path)
    end
  end

  # Override this value to specify the number of elements to display at a time
  # on index pages. Defaults to 20.
  # def records_per_page
  #   params[:per_page] || 20
  # end
end
