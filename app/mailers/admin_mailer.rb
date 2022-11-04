# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def bad_home_link(url, status, expected_statuses)
    @url = url
    @status = status
    @expected_statuses = expected_statuses
    mail(subject: "Home link to #{url} did not return expected status")
  end
end
