RSpec.describe(ApplicationCable::Channel) do
  subject(:channel) { ApplicationCable::Channel.new(connection, :current_user) }

  let(:rack_session) do
    {
      AuthenticatedSessions::Registry.session_key(:user) => authenticated_session.identifier,
    }
  end
  let(:connection) do
    ApplicationCable::Connection.new(
      ActionCable::Server::Base.new,
      {
        'rack.session' => rack_session,
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

    context 'with an impersonation AuthenticatedSession and its active parent' do
      let(:admin_user) { admin_users(:admin_user) }
      let(:parent) { admin_user.authenticated_sessions.first! }
      let(:authenticated_session) do
        user.authenticated_sessions.create!(
          authentication_kind: 'admin_impersonation',
          initial_ip: '127.0.0.1',
          latest_ip: '127.0.0.1',
          initial_user_agent: 'Test client',
          latest_user_agent: 'Test client',
          last_active_at: Time.current,
          initiated_by_authenticated_session: parent,
        )
      end
      let(:warden) do
        instance_double(Warden::Proxy).tap do |proxy|
          allow(proxy).to receive(:user).with(no_args).and_return(user)
          allow(proxy).to receive(:user).with(:admin_user).and_return(admin_user)
        end
      end

      before do
        rack_session[AuthenticatedSessions::Registry.session_key(:admin_user)] = parent.identifier
      end

      it 'accepts the connection' do
        expect { connection.connect }.not_to raise_error
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
