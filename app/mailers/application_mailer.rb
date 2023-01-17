# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # https://boringrails.com/articles/writing-better-action-mailers/
  prepend_view_path 'app/views/mailers'

  layout 'mailer'

  default(
    to: '"David Runger" <davidjrunger@gmail.com>',
    from: '"DavidRunger.com" <reply@davidrunger.com>',
    reply_to: '"DavidRunger.com" <reply@mg.davidrunger.com>',
  )
end
