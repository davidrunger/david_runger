RSpec.describe RequestRecordable, :without_verifying_authorization do
  controller(HomeController) do
    def index
      render(plain: 'This is the #index action.')
    end
  end

  describe '#store_initial_request_data_in_redis' do
    subject(:data_stashed_in_redis_after_request) do
      request.headers['User-Agent'] = user_agent
      perform_request(http_method)

      $redis_pool.with do |conn|
        JSON.parse(conn.call('get', controller.send(:initial_request_data_redis_key)))
      end
    end

    let(:http_method) { :get }
    let(:params) { {} }
    let(:user_agent) { 'RequestRecordable spec user agent' }

    context 'when a user is not logged in' do
      before { controller.sign_out_all_scopes }

      context 'when a request is made with a valid auth_token body param' do
        # For POST, Rails will provide the `params` as body params.
        let(:http_method) { :post }
        let(:params) { { auth_token: auth_token.secret } }
        let(:auth_token) { AuthToken.first! }

        it 'includes the auth token id' do
          expect(data_stashed_in_redis_after_request).to include('auth_token_id' => auth_token.id)
        end
      end

      context 'when the user agent has an invalid byte sequence' do
        let(:user_agent) { "valid bytes\xA1\xE5)" }

        it 'saves the data to Redis with the user agent string sanitized' do
          expect(data_stashed_in_redis_after_request).to include('user_agent' => 'valid bytes)')
        end
      end

      context 'when the user agent is nil' do
        let(:user_agent) { nil }

        it 'saves the data to Redis with the user agent as nil' do
          expect(data_stashed_in_redis_after_request).to include('user_agent' => nil)
        end
      end

      context 'when a JSON::GeneratorError is raised' do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Hash).to receive(:to_json).and_raise(JSON::GeneratorError, 'bad')
          # rubocop:enable RSpec/AnyInstance
        end

        it 'logs the hash and re-raises the error' do
          allow(Rails.logger).to receive(:info).and_call_original

          expect { data_stashed_in_redis_after_request }.to raise_error(JSON::GeneratorError)

          expect(Rails.logger).
            to have_received(:info).
            with(
              /\[RequestRecordable\]\[JSON::GeneratorError\].*format: :html/,
            )
        end
      end

      context 'when there is an uptime_robot param' do
        let(:params) { { 'uptime_robot' => '1' } }

        it 'does not stash initial request data in Redis' do
          perform_request

          expect($redis_pool.with { it.call('KEYS', 'request_data:*:initial') }).to eq([])
        end
      end
    end
  end

  def perform_request(http_method = :get)
    public_send(http_method, :index, params:)
  end
end
