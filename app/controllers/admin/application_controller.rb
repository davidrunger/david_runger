# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :store_request_data_in_redis
    before_action :authenticate_admin

    def authenticate_admin
      unless current_user&.email == 'davidjrunger@gmail.com'
        sign_out_all_scopes
        redirect_to(login_path)
      end
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    def store_request_data_in_redis
      $redis.setex(
        params['request_uuid'],
        ::ApplicationController::REQUEST_DATA_TTL,
        {admin: true}.to_json
      )
    end
  end
end
