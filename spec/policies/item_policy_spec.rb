RSpec.describe(ItemPolicy) do
  subject(:policy) { ItemPolicy.new(user, item) }

  let(:item) { users(:user).items.first! }

  describe '#update?' do
    subject(:update?) { policy.update? }

    context 'when the user is the owner of the item' do
      let(:user) { item.user }

      it 'returns true' do
        expect(update?).to eq(true)
      end
    end

    context 'when the user is the spouse of the owner of the item' do
      let(:user) { item.user.spouse.presence! }

      it 'returns true' do
        expect(update?).to eq(true)
      end
    end

    context "when the user is not the item's owner or owner's spouse" do
      let(:user) { User.where.not(id: [item.user, item.user.spouse]).first! }

      it 'returns false' do
        expect(update?).to eq(false)
      end
    end

    context 'when the user is not married' do
      let(:user) { users(:single_user) }

      context 'when the user is the owner of the item' do
        let(:item) { create(:item, stores: [user.stores.first!]) }

        it 'returns true' do
          expect(update?).to eq(true)
        end
      end
    end
  end

  describe '#destroy?' do
    subject(:destroy?) { policy.destroy? }

    context 'when the user is the owner of the item' do
      let(:user) { item.user }

      it 'returns true' do
        expect(destroy?).to eq(true)
      end
    end

    context 'when the user is the spouse of the owner of the item' do
      let(:user) { item.user.spouse.presence! }

      it 'returns false' do
        expect(destroy?).to eq(false)
      end
    end

    context "when the user is not the item's owner or owner's spouse" do
      let(:user) { User.where.not(id: [item.user, item.user.spouse]).first! }

      it 'returns false' do
        expect(destroy?).to eq(false)
      end
    end
  end

  describe '#manage_availabilities?' do
    subject(:manage_availabilities?) { policy.manage_availabilities? }

    context 'when the user is the owner of the item' do
      let(:user) { item.user }

      it 'returns true' do
        expect(manage_availabilities?).to eq(true)
      end
    end

    context 'when the user is the spouse of the owner of the item' do
      let(:user) { item.user.spouse.presence! }

      it 'returns false' do
        expect(manage_availabilities?).to eq(false)
      end
    end

    context "when the user is not the item's owner or owner's spouse" do
      let(:user) { User.where.not(id: [item.user, item.user.spouse]).first! }

      it 'returns false' do
        expect(manage_availabilities?).to eq(false)
      end
    end
  end

  describe '#merge?' do
    subject(:merge?) { policy.merge? }

    context 'when the user is the owner of the item' do
      let(:user) { item.user }

      it 'returns true' do
        expect(merge?).to eq(true)
      end
    end

    context 'when the user is the spouse of the owner of the item' do
      let(:user) { item.user.spouse.presence! }

      it 'returns false' do
        expect(merge?).to eq(false)
      end
    end

    context "when the user is not the item's owner or owner's spouse" do
      let(:user) { User.where.not(id: [item.user, item.user.spouse]).first! }

      it 'returns false' do
        expect(merge?).to eq(false)
      end
    end
  end
end
