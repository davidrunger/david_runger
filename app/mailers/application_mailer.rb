# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default(
    to: 'David Runger <davidjrunger@gmail.com>',
    from: 'DavidRunger.com <noreply@davidrunger.com>',
  )
  layout 'mailer'
end
