RSpec.describe MarriageMembership do
  describe 'validations' do
    context 'when a marriage has two partners' do
      let(:marriage) do
        Marriage.
          joins(:partners).
          group(marriages: :id).
          having('COUNT(DISTINCT users.id) = 2').
          first!
      end
      let(:other_user) { User.where.not(id: marriage.partners).first! }

      it 'considers the first two memberships valid and does not permit the addition of a third partner' do
        expect(marriage.reload.partners.size).to eq(2)
        expect(marriage.memberships.map(&:valid?)).to eq([true, true])

        expect {
          marriage.partners << other_user
        }.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: No more than two partners may join a marriage',
        )

        expect(marriage.reload.partners.size).to eq(2)
      end
    end
  end
end
