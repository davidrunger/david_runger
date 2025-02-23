class GenericMailer < ApplicationMailer
  def generic_html(to, subject, html_body)
    mail(to:, subject:, body: html_body, content_type: 'text/html')
  end
end
