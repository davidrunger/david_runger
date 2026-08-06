RSpec.describe ProposalMailer do
  describe '#proposal_created' do
    subject(:mail) { described_class.proposal_created(proposal.id) }

    let(:proposal) { create(:proposal) }

    it 'sends the proposal to its intended recipient' do
      expect(mail.to).to eq([proposal.proposee_email])
      expect(mail.subject).
        to eq("#{proposal.proposer.email} wants you to join their marriage on davidrunger.com")
    end

    it 'links to the recipient-bound confirmation page without a query string' do
      expect(mail.body.to_s).to include(confirm_proposal_url(proposal))
      expect(mail.body.to_s).not_to include('token=')
    end
  end
end
