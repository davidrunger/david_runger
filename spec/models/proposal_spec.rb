RSpec.describe Proposal do
  describe 'creation' do
    subject(:proposal) do
      create(
        :proposal,
        proposee_email: '  Proposed.Spouse@Example.COM  ',
      )
    end

    it 'normalizes the proposee email and generates a public identifier' do
      expect(proposal.proposee_email).to eq('proposed.spouse@example.com')
      expect(proposal.public_id).to be_present
      expect(proposal.to_param).to eq(proposal.public_id)
    end
  end

  describe '.pending' do
    let!(:pending_proposal) { create(:proposal) }

    before { create(:proposal, accepted_at: 1.minute.ago) }

    it 'returns only proposals that have not been accepted' do
      expect(described_class.pending).to contain_exactly(pending_proposal)
    end

    it 'excludes canceled proposals' do
      pending_proposal.update!(canceled_at: 1.minute.ago)

      expect(described_class.pending).to be_empty
    end
  end

  describe 'proposee email format' do
    it 'rejects an invalid email address' do
      proposal = build(:proposal, proposee_email: 'not-an-email-address')

      expect(proposal).not_to be_valid
      expect(proposal.errors.full_messages_for(:proposee_email)).
        to eq(['Proposee email is invalid'])
    end

    it 'leaves blank email addresses to presence validation' do
      proposal = build(:proposal, proposee_email: '')

      expect(proposal).not_to be_valid
      expect(proposal.errors.full_messages_for(:proposee_email)).
        to eq(["Proposee email can't be blank"])
    end
  end

  describe 'proposee email uniqueness' do
    let(:pending_proposal) { create(:proposal) }

    it 'does not allow duplicate pending proposals from the same proposer' do
      duplicate_proposal =
        build(
          :proposal,
          proposer: pending_proposal.proposer,
          proposee_email: pending_proposal.proposee_email,
        )

      expect(duplicate_proposal).not_to be_valid
      expect(duplicate_proposal.errors[:proposee_email]).to include('has already been taken')
    end

    it 'allows another proposal after the earlier proposal has been accepted' do
      pending_proposal.update!(accepted_at: 1.minute.ago)

      expect(
        build(
          :proposal,
          proposer: pending_proposal.proposer,
          proposee_email: pending_proposal.proposee_email,
        ),
      ).to be_valid
    end

    it 'allows another proposal after the earlier proposal has been canceled' do
      pending_proposal.update!(canceled_at: 1.minute.ago)

      expect(
        build(
          :proposal,
          proposer: pending_proposal.proposer,
          proposee_email: pending_proposal.proposee_email,
        ),
      ).to be_valid
    end
  end
end
