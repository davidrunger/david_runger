RSpec.describe Proposals::Cancel do
  subject(:run) { described_class.new(proposal:).run }

  let!(:proposal) { create(:proposal) }

  it 'marks the proposal as canceled', :frozen_time do
    expect {
      expect(run).to be_success
    }.to change {
      proposal.reload.canceled_at
    }.from(nil).to(Time.current)
  end

  context 'when the proposal has already been canceled' do
    before { proposal.update!(canceled_at: 1.minute.ago) }

    it 'succeeds without changing the cancellation time' do
      expect {
        expect(run).to be_success
      }.not_to change {
        proposal.reload.canceled_at
      }
    end
  end

  context 'when the proposal has already been accepted' do
    before { proposal.update!(accepted_at: 1.minute.ago) }

    it 'does not cancel the proposal' do
      expect(run).not_to be_success
      expect(run.error_message).to eq('This proposal has already been accepted.')
      expect(proposal.reload.canceled_at).to be_nil
    end
  end
end
