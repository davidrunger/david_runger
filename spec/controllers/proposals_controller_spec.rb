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
      around do |spec|
        ClimateControl.modify(JWT_SECRET: 'zyx432') do
          spec.run
        end
      end

      context 'when the proposer and proposee each have their own (unpartnered) marriages' do
        before do
          proposer.marriage&.destroy!
          create(:marriage, partner_1: proposer, partner_2: nil)
          proposee.marriage&.destroy!
          create(:marriage, partner_1: proposee, partner_2: nil)
        end

        let!(:proposer_marriage) { proposer.marriage }
        let!(:proposee_marriage_id) { proposee.marriage.id }

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
