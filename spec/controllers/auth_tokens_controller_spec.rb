# frozen_string_literal: true

RSpec.describe AuthTokensController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create) }

    it 'creates an auth token for the user' do
      expect { post_create }.to change { user.reload.auth_tokens.size }.by(1)
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: auth_token.id }) }

    let(:auth_token) { user.auth_tokens.first! }

    it 'destroys the specified auth token' do
      expect { delete_destroy }.
        to change { user.reload.auth_tokens.where(id: auth_token).size }.
        by(-1)
    end
  end

  describe '#update' do
    subject(:patch_update) do
      patch(
        :update,
        params: {
          id: auth_token.id,
          auth_token: {
            name: new_auth_token_name,
            secret: new_auth_token_secret,
          },
        },
      )
    end

    let(:auth_token) { user.auth_tokens.first! }
    let(:new_auth_token_name) { 'Travis CI run times' }
    let(:new_auth_token_secret) { SecureRandom.uuid }

    it 'updates the specified auth token' do
      expect {
        patch_update
      }.to change {
        auth_token.reload.attributes.values_at(*%w[name secret])
      }.to([new_auth_token_name, new_auth_token_secret])
    end
  end
end
