# frozen_string_literal: true

RSpec.describe(AuthTokens::Create) do
  subject(:action) { AuthTokens::Create.new!(user:) }

  let(:user) { users(:user) }

  describe '#run!' do
    subject(:run!) { action.run! }

    it 'creates an AuthToken for the user' do
      expect { run! }.to change { user.auth_tokens.count }.by(1)
    end
  end
end
