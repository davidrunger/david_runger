class ProposalMailer < ApplicationMailer
  def proposal_created(proposal_id)
    @proposal = Proposal.find(proposal_id)
    @proposer = @proposal.proposer
    mail(
      to: @proposal.proposee_email,
      subject: %(#{@proposer.email} wants you to join their marriage on davidrunger.com),
    )
  end
end
