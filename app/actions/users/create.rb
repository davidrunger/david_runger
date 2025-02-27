class Users::Create < ApplicationAction
  requires :email, String
  requires :google_sub, String

  returns :user, User

  def execute
    result.user = User.create!(email:, google_sub:)
    AdminMailer.user_created(result.user.id).deliver_later
  end
end
