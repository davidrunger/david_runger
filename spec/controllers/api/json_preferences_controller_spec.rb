RSpec.describe Api::JsonPreferencesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#update' do
    subject(:patch_update) { patch(:update, params:) }

    context 'when the params are valid' do
      let(:params) { valid_params }
      let(:valid_params) do
        {
          preference_type: JsonPreference::Types::EMOJI_BOOSTS,
          json: emoji_boosts_array,
        }
      end
      let(:emoji_boosts_array) { [{ 'symbol' => '🙂', 'boostedName' => 'happy' }] }

      it 'returns a 200 status code' do
        patch_update

        expect(response).to have_http_status(200)
      end

      it "updates the user's JsonPreference" do
        expect { patch_update }.
          to change { user.reload.emoji_boosts.json }.
          to(emoji_boosts_array)
      end

      it 'responds with the JsonPreference#json as JSON' do
        patch_update

        expect(response.parsed_body).to eq(emoji_boosts_array)
      end
    end

    context 'when the params are invalid' do
      let(:params) { valid_params }
      let(:valid_params) do
        {
          preference_type: JsonPreference::Types::EMOJI_BOOSTS,
          json: nil,
        }
      end

      it 'returns a 422 status code and no content' do
        patch_update

        expect(response).to have_http_status(422)
        expect(response.body).to eq('')
      end

      it "does not change the user's JsonPreference" do
        expect { patch_update }.
          not_to change { user.reload.emoji_boosts.json }
      end
    end
  end
end
