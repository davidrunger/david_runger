RSpec.describe Proposals::Accept do
  subject(:action) do
    Proposals::Accept.new(
      encoded_token:
        JWT.encode(
          { proposer_id: proposer.id },
          ENV.fetch('JWT_SECRET'),
          'HS512',
        ),
      proposee:,
    )
  end

  let!(:proposer) { users(:user) }
  let!(:proposee) { User.where.missing(:marriage).except(proposer).first! }

  describe '#run' do
    subject(:run) { action.run }

    context 'when the proposer has deleted their marriage' do
      before { proposer&.marriage&.destroy! }

      it 'creates a new marriage with proposer and proposee as partners' do
        expect {
          run
        }.to change {
          proposer.reload.marriage
        }.from(nil).to(Marriage)
      end
    end

    context "when the proposee's marriage has dependent check-in data" do
      let!(:proposer) { create(:user) }
      let!(:proposee) { create(:user) }
      let!(:proposee_marriage) do
        Marriages::Create.run!(proposer: proposee)
        proposee.reload.marriage
      end
      let!(:check_in) { CheckIns::Create.run!(marriage: proposee_marriage).check_in }

      it 'destroys the marriage and its dependent records without N+1 queries' do
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
      end
    end
  end
end
