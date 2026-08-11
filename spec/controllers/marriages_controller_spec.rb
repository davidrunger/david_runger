RSpec.describe MarriagesController do
  describe '#new' do
    subject(:get_new) { get(:new) }

    let(:user) { users(:single_user) }

    before { sign_in(user) }

    it "assigns the current user's pending proposals" do
      pending_proposal = create(:proposal, proposer: user)
      canceled_proposal = create(:proposal, proposer: user, canceled_at: 1.minute.ago)

      get_new

      expect(assigns[:pending_proposals]).to contain_exactly(pending_proposal)
      expect(assigns[:pending_proposals]).not_to include(canceled_proposal)
    end
  end
end
