# frozen_string_literal: true

class NewUserMailer < ApplicationMailer
  def user_created(user_id)
    @user = User.find(user_id)
    mail(subject: "There's a new davidrunger.com user! :) Email: #{@user.email}.")
  end
end
