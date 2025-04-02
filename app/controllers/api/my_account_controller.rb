class Api::MyAccountController < Api::BaseController
  def update
    authorize(current_user)

    current_user.update!(my_account_params)

    render_schema_json(UserSerializer::Public.new(current_user))
  end

  private

  def my_account_params
    params.expect(user: %i[public_name])
  end
end
