class MailgunInboundEmailsController < ActionMailbox::Ingresses::Mailgun::InboundEmailsController
  class IngressRateLimitReached < StandardError ; end

  REQUEST_LIMIT = 100
  RATE_LIMIT_REACHED_MESSAGE = 'Mailgun inbound email rate limit reached.'

  rate_limit(
    to: REQUEST_LIMIT,
    within: 1.day,
    by: -> { 'all' },
    with: :mailgun_ingress_rate_limit_reached,
    only: :create,
  )

  private

  def ingress_name = :mailgun

  def mailgun_ingress_rate_limit_reached
    Rails.error.report(
      Error.new(IngressRateLimitReached, RATE_LIMIT_REACHED_MESSAGE),
      severity: :warning,
      context: { request_limit: REQUEST_LIMIT },
    )
    head :too_many_requests
  end
end
