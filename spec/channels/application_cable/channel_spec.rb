RSpec.describe(ApplicationCable::Channel) do
  subject(:channel) { ApplicationCable::Channel.new(connection, :current_user) }

  let(:connection) do
    ApplicationCable::Connection.new(
      ActionCable::Server::Base.new,
      {
        'rack.session' => {
          AuthenticatedSessions::Registry.session_key(:user) => authenticated_session.identifier,
        },
        'warden' => warden,
      },
    )
  end
  let(:warden) { instance_double(Warden::Proxy, user:) }
  let(:user) { User.first! }
  let(:authenticated_session) do
    user.authenticated_sessions.create!(
      authentication_kind: 'legacy',
      initial_ip: '127.0.0.1',
      latest_ip: '127.0.0.1',
      initial_user_agent: 'Test client',
      latest_user_agent: 'Test client',
      last_active_at: Time.current,
      revoked_at:,
    )
  end
  let(:revoked_at) { nil }

  describe '#connect' do
    context 'with an active AuthenticatedSession' do
      it 'identifies the connection with the specific session' do
        connection.connect

        expect(connection.authenticated_session_identifier).to eq(authenticated_session.identifier)
      end
    end

    context 'with a revoked AuthenticatedSession' do
      let(:revoked_at) { Time.current }

      it 'rejects the new connection' do
        expect { connection.connect }.
          to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end
  end

  describe '#authorize!' do
    subject(:authorize!) { channel.authorize!(record, policy_query) }

    let(:record) { log }
    let(:log) { Log.first! }
    let(:policy_query) { :show? }

    before { connection.connect }

    context 'when there is a current_user' do
      let(:user) { User.where.not(id: record.user_id).first! }

      context 'when the user is not authorized to view the record' do
        before { log.log_shares.find_each(&:destroy!) }

        it 'raises an error with an error message including "User:<user id>"' do
          expect { authorize! }.to raise_error(
            Pundit::NotAuthorizedError,
            "LogPolicy says that User:#{user.id} is not authorized to show? Log:#{log.id}",
          )
        end
      end

      context 'when the user is authorized to view the record' do
        let(:user) { record.user }

        it 'does not raise an error' do
          expect { authorize! }.not_to raise_error
        end
      end
    end
  end
end
