# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # https://boringrails.com/articles/writing-better-action-mailers/
  prepend_view_path 'app/views/mailers'

  layout 'mailer'

  default(
    to: email_address_with_name('davidjrunger@gmail.com', 'David Runger'),
    from: email_address_with_name('reply@davidrunger.com', 'DavidRunger.com'),
    reply_to: email_address_with_name('reply@mg.davidrunger.com', 'DavidRunger.com'),
  )
end
