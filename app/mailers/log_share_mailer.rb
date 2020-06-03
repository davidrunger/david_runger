# frozen_string_literal: true

class LogShareMailer < ApplicationMailer
  def log_shared(log_share_id)
    log_share = LogShare.find(log_share_id)
    @log = log_share.log
    mail(
      to: log_share.email,
      subject: %(#{@log.user.email} shared their "#{@log.name}" log with you),
    )
  end
end
