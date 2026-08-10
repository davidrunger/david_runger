class Api::WebhookEmailForwardsController < Api::BaseController
  allow_auth_token_authorization

  def create
    authorize(:create?, policy_class: WebhookEmailForwardPolicy)

    subject = params[:title]
    html_body = params[:message]
    delivery_limit =
      Email::UserGeneratedDeliveryLimiter.reserve_global(
        category: :webhook_email_forward,
      )

    if delivery_limit.permitted?
      GenericMailer.generic_html(
        current_or_auth_token_user.email,
        subject,
        html_body,
      ).deliver_later
    end

    head :created
  end
end
