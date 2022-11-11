# frozen_string_literal: true

RSpec.describe(ProposalsController) do
  describe '#accept' do
    subject(:get_accept) { get(:accept, params:) }

    let(:params) do
      {
        token: JWT.encode(
          { proposer_id: proposer.id },
          Rails.application.credentials.jwt_secret!,
          'HS512',
        ),
      }
    end
    let(:proposer) { users(:admin) }
    let(:proposee) { users(:user) }

    context 'when a jwt_secret credential is available' do
      before do
        expect(Rails.application.credentials).
          to receive(:jwt_secret!).
          at_least(:once).
          and_return('xyzdef2481632')
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
