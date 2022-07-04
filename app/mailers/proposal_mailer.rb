# frozen_string_literal: true

class ProposalMailer < ApplicationMailer
  def proposal_created(proposer_id, proposee_email)
    proposer = User.find(proposer_id)
    @token = JWT.encode({ proposer_id: }, Rails.application.credentials.jwt_secret!, 'HS512')
    mail(
      to: proposee_email,
      subject: %(#{proposer.email} wants you to join their marriage on DavidRunger.com),
    )
  end
end
