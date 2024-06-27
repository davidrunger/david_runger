# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def broken_link(url, page_source_url, status, expected_statuses)
    @url = url
    @page_source_url = page_source_url
    @status = status
    @expected_statuses = expected_statuses

    mail(subject: "Link to #{url} did not return expected status")
  end

  def user_created(user_id)
    @user = User.find(user_id)
    mail(subject: "There's a new davidrunger.com user! :) Email: #{@user.email}.")
  end
end
