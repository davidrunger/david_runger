# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default(
    to: '"David Runger" <davidjrunger@gmail.com>',
    from: '"DavidRunger.com" <reply@davidrunger.com>',
    reply_to: '"DavidRunger.com" <reply@mg.davidrunger.com>',
  )
  layout 'mailer'
end
