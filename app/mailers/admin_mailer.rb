# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def bad_home_link(url, status, expected_status)
    @url = url
    @status = status
    @expected_status = expected_status
    mail(subject: "Home link to #{url} did not return expected status")
  end
end
