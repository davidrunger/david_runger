RSpec.describe StorePolicy do
  subject(:policy) { described_class.new(user, store) }

  let(:store) { user.stores.first! }

  describe '#scope' do
    subject(:scope) { policy.scope }

    context 'when the user has a spouse' do
      let(:user) { users(:user) }
      let(:public_spouse_store) do
        user.spouse.presence!.stores.find_by!(private: false)
      end
      let(:private_spouse_store) do
        user.spouse.presence!.stores.find_by!(private: true)
      end

      it 'returns the own stores and public spouse stores' do
        expect(scope).to match_array(user.stores + [public_spouse_store])
        expect(scope).not_to include(private_spouse_store)
      end
    end

    context 'when the user does not have a spouse' do
      let(:user) { users(:single_user) }

      it 'returns the own stores' do
        expect(scope).to match_array(user.stores)
      end
    end
  end
end
