RSpec.describe MarriagePolicy do
  subject(:policy) { described_class.new(user, marriage) }

  let(:partner) { create(:user) }
  let(:marriage) { create(:marriage, partners: [partner, create(:user)]) }

  describe '#destroy?' do
    context 'when the user is a partner in the marriage' do
      let(:user) { partner }

      it 'allows ending the marriage' do
        expect(policy.destroy?).to eq(true)
      end
    end

    context 'when the user is not a partner in the marriage' do
      let(:user) { create(:user) }

      it 'forbids ending the marriage' do
        expect(policy.destroy?).to eq(false)
      end
    end

    context 'when the marriage has only one partner' do
      let(:user) { partner }
      let(:marriage) { create(:marriage, partners: [partner]) }

      it 'forbids ending the marriage' do
        expect(policy.destroy?).to eq(false)
      end
    end
  end
end
