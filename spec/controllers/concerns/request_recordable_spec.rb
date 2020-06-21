# frozen_string_literal: true

RSpec.describe RequestRecordable do
  controller(ApplicationController) do
    def index
      render(plain: 'This is the #index action.')
    end
  end

  describe '#store_initial_request_data_in_redis' do
    subject(:data_stashed_in_redis_after_request) do
      get(:index, params: params)

      $redis_pool.with do |conn|
        JSON(conn.get(controller.send(:initial_request_data_redis_key)))
      end
    end

    context 'when a user is not logged in' do
      before { controller.sign_out_all_scopes }

      context 'when a request is made with a valid auth_token param' do
        let(:params) { { auth_token: auth_token.secret } }
        let(:auth_token) { AuthToken.first! }

        it 'includes the auth token id' do
          expect(data_stashed_in_redis_after_request).to include('auth_token_id' => auth_token.id)
        end
      end
    end
  end
end
