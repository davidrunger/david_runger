class ProposalMailer < ApplicationMailer
  def proposal_created(proposer_id, proposee_email)
    @proposer = User.find(proposer_id)
    @token = JWT.encode({ proposer_id: }, ENV.fetch('JWT_SECRET'), 'HS512')
    mail(
      to: proposee_email,
      subject: %(#{@proposer.email} wants you to join their marriage on davidrunger.com),
    )
  end
end
