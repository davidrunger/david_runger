RSpec.describe(ProposalsController) do
  describe '#accept' do
    subject(:get_accept) { get(:accept, params:) }

    let(:params) do
      {
        token: JWT.encode(
          { proposer_id: proposer.id },
          ENV.fetch('JWT_SECRET'),
          'HS512',
        ),
      }
    end
    let(:proposer) { users(:single_user) }
    let(:proposee) { users(:user) }

    context 'when JWT_SECRET is set' do
      before { expect(ENV.fetch('JWT_SECRET', nil)).to be_present }

      context 'when the proposer and proposee each have their own (unpartnered) marriages' do
        before do
          proposer.marriage&.destroy!
          create(:marriage, partners: [proposer])
          proposee.marriage&.destroy!
          create(:marriage, partners: [proposee])
        end

        let!(:proposer_marriage) { proposer.reload.marriage }
        let!(:proposee_marriage_id) { proposee.reload.marriage.id }

        context 'when the proposee is signed in' do
          before { sign_in(proposee) }

          it "destroys the proposee's preexisting marriage" do
            expect {
              get_accept
            }.to change {
              Marriage.find_by(id: proposee_marriage_id)
            }.from(Marriage).to(nil)
          end

          it "adds the proposee to the proposer's marriage" do
            expect {
              get_accept
            }.to change {
              proposer_marriage.reload.partners.compact.sort
            }.from([proposer]).to([proposer, proposee].sort)
          end
        end
      end
    end
  end
end
