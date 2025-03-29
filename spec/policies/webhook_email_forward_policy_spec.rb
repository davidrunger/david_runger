RSpec.describe WebhookEmailForwardPolicy do
  subject(:policy) { described_class.new(user, nil) }

  describe '#create?' do
    subject(:create?) { policy.create? }

    context 'when there is a user' do
      let(:user) { users(:user) }

      it 'returns true' do
        expect(create?).to eq(true)
      end
    end

    context 'when there is no user' do
      let(:user) { nil }

      it 'returns false' do
        expect(create?).to eq(false)
      end
    end
  end
end
