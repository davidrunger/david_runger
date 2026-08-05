RSpec.describe Proposals::Accept do
  subject(:run) do
    described_class.new(
      proposal:,
      proposee:,
    ).run
  end

  let(:proposer) { create(:user) }
  let(:proposee) { create(:user) }
  let!(:proposal) { create(:proposal, proposer:, proposee_email: proposee.email) }

  context 'when the proposal can be accepted' do
    let!(:proposer_marriage) { create(:marriage, partners: [proposer]) }
    let!(:proposee_marriage) { create(:marriage, partners: [proposee]) }

    it "replaces the proposee's marriage with the proposer's marriage" do
      expect {
        expect(run).to be_success
      }.to change {
        Marriage.exists?(proposee_marriage.id)
      }.from(true).to(false).and change {
        proposer_marriage.reload.partners.order(:id).to_a
      }.from([proposer]).to([proposer, proposee].sort_by(&:id))
    end

    it 'marks the proposal as accepted' do
      expect {
        run
      }.to change {
        proposal.reload.accepted_at
      }.from(nil)
    end
  end

  context 'when the proposer does not have a marriage' do
    let!(:proposee_marriage) { create(:marriage, partners: [proposee]) }

    it 'creates a new marriage for the proposer and proposee' do
      expect {
        expect(run).to be_success
      }.to change {
        proposer.reload.marriage
      }.from(nil).to(Marriage)

      expect(proposer.marriage.partners.order(:id)).to eq([proposer, proposee].sort_by(&:id))
      expect(Marriage.exists?(proposee_marriage.id)).to eq(false)
    end
  end

  context "when the proposee's marriage has dependent check-in data" do
    let!(:proposer_marriage) { create(:marriage, partners: [proposer]) }
    let!(:proposee_marriage) do
      Marriages::Create.run!(proposer: proposee)
      proposee.reload.marriage
    end
    let!(:check_in) { CheckIns::Create.run!(marriage: proposee_marriage).check_in }

    it 'destroys the marriage and all dependent records without N+1 queries' do
      expect(proposee_marriage.emotional_needs.size).
        to eq(Marriages::Create::DEFAULT_EMOTIONAL_NEEDS.size)
      expect(check_in.need_satisfaction_ratings.size).
        to eq(Marriages::Create::DEFAULT_EMOTIONAL_NEEDS.size)

      expect {
        expect(run).to be_success
      }.to change {
        Marriage.exists?(proposee_marriage.id)
      }.from(true).to(false).and change {
        NeedSatisfactionRating.where(check_in:).count
      }.to(0)

      expect(proposer_marriage.reload.partners).to contain_exactly(proposer, proposee)
    end
  end

  context 'when the proposer and proposee are already in the same marriage' do
    let!(:marriage) { create(:marriage, partners: [proposer, proposee]) }

    it 'marks the proposal accepted without replacing the marriage' do
      expect {
        expect(run).to be_success
      }.not_to change {
        proposer.reload.marriage.id
      }.from(marriage.id)

      expect(proposal.reload.accepted_at).to be_present
    end
  end

  context 'when the proposal has already been accepted' do
    before { proposal.update!(accepted_at: 1.minute.ago) }

    let!(:proposee_marriage) { create(:marriage, partners: [proposee]) }

    it 'rejects the replay without changing the proposee marriage' do
      expect {
        expect(run).not_to be_success
      }.not_to change {
        proposee.reload.marriage.id
      }.from(proposee_marriage.id)

      expect(run.error_message).to eq('This proposal has already been accepted.')
    end
  end

  context 'when the proposal was sent to a different user' do
    let(:proposee) { create(:user) }

    before { proposal.update!(proposee_email: create(:user).email) }

    it 'rejects the proposal before changing any marriage' do
      expect(run).not_to be_success
      expect(run.error_message).to eq('This proposal was sent to a different email address.')
      expect(proposal.reload.accepted_at).to be_nil
    end
  end

  context 'when the proposer tries to accept their own proposal' do
    let(:proposee) { proposer }

    it 'rejects the proposal' do
      expect(run).not_to be_success
      expect(run.error_message).to eq('You cannot accept your own proposal.')
      expect(proposal.reload.accepted_at).to be_nil
    end
  end

  context "when the proposer's marriage already has two partners" do
    let!(:proposer_marriage) { create(:marriage, partners: [proposer, create(:user)]) }
    let!(:proposee_marriage) { create(:marriage, partners: [proposee]) }

    it "rejects the proposal before destroying the proposee's marriage" do
      expect {
        expect(run).not_to be_success
      }.not_to change {
        proposee.reload.marriage.id
      }.from(proposee_marriage.id)

      expect(run.error_message).
        to eq("#{proposer.email}'s marriage already has two partners.")
      expect(proposer.reload.marriage).to eq(proposer_marriage)
      expect(proposal.reload.accepted_at).to be_nil
    end
  end

  context 'when marking the proposal accepted fails' do
    let!(:proposer_marriage) { create(:marriage, partners: [proposer]) }
    let!(:proposee_marriage) { create(:marriage, partners: [proposee]) }

    before do
      allow(proposal).
        to receive(:update!).
        and_raise(ActiveRecord::RecordInvalid.new(proposal))
    end

    it 'rolls back all relationship changes' do
      expect {
        run
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(proposer_marriage.reload.partners).to contain_exactly(proposer)
      expect(proposee_marriage.reload.partners).to contain_exactly(proposee)
      expect(proposal.reload.accepted_at).to be_nil
    end
  end

  context 'when a later relationship change follows a successful acceptance' do
    let!(:proposer_marriage) { create(:marriage, partners: [proposer]) }

    it 'cannot replay the accepted proposal to destroy the later relationship' do
      expect(run).to be_success
      proposer_marriage.reload.destroy!
      later_marriage = create(:marriage, partners: [proposee, create(:user)])

      replay_result =
        described_class.new(
          proposal: proposal.reload,
          proposee: proposee.reload,
        ).run

      expect(replay_result).not_to be_success
      expect(replay_result.error_message).to eq('This proposal has already been accepted.')
      expect(proposee.reload.marriage).to eq(later_marriage)
    end
  end
end
