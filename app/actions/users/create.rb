# frozen_string_literal: true

class Users::Create < ApplicationAction
  requires :email, String

  returns :user, User

  def execute
    result.user = User.create!(email: email)
    NewUserMailer.user_created(result.user.id).deliver_later
  end
end
