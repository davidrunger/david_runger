RSpec.describe ProposalPolicy do
  subject(:policy) { described_class.new(user, proposal) }

  let(:proposal) { create(:proposal, proposee_email: intended_user.email) }
  let(:intended_user) { create(:user) }

  describe '#create?' do
    subject(:create?) { described_class.new(user, Proposal).create? }

    let(:user) { create(:user) }

    context 'when the user does not have a marriage' do
      it { is_expected.to eq(true) }
    end

    context 'when the user has a solo marriage' do
      before { create(:marriage, partners: [user]) }

      it { is_expected.to eq(true) }
    end

    context 'when the user has a spouse' do
      before { create(:marriage, partners: [user, create(:user)]) }

      it { is_expected.to eq(false) }
    end
  end

  context 'when the user is the intended recipient' do
    let(:user) { intended_user }

    it 'allows viewing the confirmation and accepting the proposal' do
      expect(policy.confirm?).to eq(true)
      expect(policy.accept?).to eq(true)
    end

    it 'does not allow canceling the proposal' do
      expect(policy.cancel?).to eq(false)
    end
  end

  context 'when the user is not the intended recipient' do
    let(:user) { create(:user) }

    it 'forbids viewing the confirmation, accepting, or canceling the proposal' do
      expect(policy.confirm?).to eq(false)
      expect(policy.accept?).to eq(false)
      expect(policy.cancel?).to eq(false)
    end
  end

  context 'when the user is the proposer' do
    let(:user) { proposal.proposer }

    it 'allows canceling the proposal' do
      expect(policy.cancel?).to eq(true)
    end
  end
end
