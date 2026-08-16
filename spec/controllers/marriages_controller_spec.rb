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

  describe '#destroy' do
    subject(:delete_marriage) { delete(:destroy) }

    let(:user) { users(:user) }
    let(:spouse) { users(:married_user) }
    let(:marriage) { user.marriage.presence! }
    let!(:check_in) { marriage.check_ins.first! }
    let!(:emotional_need) { marriage.emotional_needs.first! }

    before { sign_in(user) }

    it 'ends the marriage for both partners' do
      expect { delete_marriage }.
        to change { Marriage.exists?(marriage.id) }.
        from(true).to(false)

      expect(user.reload.marriage).to be_nil
      expect(spouse.reload.marriage).to be_nil
      expect(CheckIn.exists?(check_in.id)).to eq(false)
      expect(EmotionalNeed.exists?(emotional_need.id)).to eq(false)
      expect(response).to redirect_to(check_ins_path)
      expect(flash[:notice]).to eq('Your marriage has been ended.')
    end
  end
end
