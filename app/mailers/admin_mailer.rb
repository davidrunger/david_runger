# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def bad_home_link(url, status, expected_statuses)
    @url = url
    @status = status
    @expected_statuses = expected_statuses
    mail(subject: "Home link to #{url} did not return expected status")
  end

  def user_created(user_id)
    @user = User.find(user_id)
    mail(subject: "There's a new davidrunger.com user! :) Email: #{@user.email}.")
  end
end
