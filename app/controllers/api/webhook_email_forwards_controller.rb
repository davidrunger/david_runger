class Api::WebhookEmailForwardsController < Api::BaseController
  def create
    authorize(:create?, policy_class: WebhookEmailForwardPolicy)

    subject = params[:title]
    html_body = params[:message]
    GenericMailer.generic_html(
      current_or_auth_token_user.email,
      subject,
      html_body,
    ).deliver_later

    head :created
  end
end
