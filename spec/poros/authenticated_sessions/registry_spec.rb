RSpec.describe AuthenticatedSessions::Registry do
  let(:rack_session) { {} }
  let(:observed_ip) { Faker::Internet.ip_v4_address }
  let(:env) do
    {
      'HTTP_USER_AGENT' => 'Test Browser/1.0',
      'REMOTE_ADDR' => observed_ip,
      'rack.session' => rack_session,
    }
  end
  let(:request) { ActionDispatch::Request.new(env) }
  let(:warden) { instance_double(Warden::Proxy, request:, logout: true) }
  let(:user) { users(:user) }
  let(:admin_user) { admin_users(:admin_user) }

  before { allow(warden).to receive(:user).and_return(nil) }

  describe '.enforce!' do
    it 'raises for a scope not managed by the registry' do
      expect {
        enforce(user, scope: :unmanaged, event: :fetch)
      }.to raise_error(ArgumentError, 'Unsupported Warden scope: :unmanaged')
    end

    it 'raises when the authenticatable does not match the Warden scope' do
      expect {
        enforce(admin_user, scope: :user, event: :fetch)
      }.to raise_error(
        ArgumentError,
        'Expected User for Warden scope :user, got AdminUser',
      )
    end

    it 'registers a fresh OAuth User login with request metadata' do
      env['authenticated_session.authentication_kind.user'] = 'google_oauth'

      expect { enforce(user, scope: :user, event: :set_user) }.
        to change { user.authenticated_sessions.count }.by(1)

      authenticated_session = user.authenticated_sessions.last!
      expect(authenticated_session.authentication_kind).to eq('google_oauth')
      expect(authenticated_session.attributes.values_at('initial_ip', 'latest_ip')).
        to eq([observed_ip, observed_ip])
      expect(
        authenticated_session.attributes.values_at('initial_user_agent', 'latest_user_agent'),
      ).to eq(['Test Browser/1.0', 'Test Browser/1.0'])
    end

    it 'raises when a fresh authentication has no registered kind' do
      expect {
        enforce(user, scope: :user, event: :authentication)
      }.to raise_error(
        ArgumentError,
        'No authentication kind registered for fresh Warden authentication in scope :user',
      )
    end

    it 'uses distinct identifiers for User and AdminUser scopes' do
      env['authenticated_session.authentication_kind.user'] = 'google_oauth'
      env['authenticated_session.authentication_kind.admin_user'] = 'google_oauth'

      enforce(user, scope: :user, event: :authentication)
      enforce(admin_user, scope: :admin_user, event: :authentication)

      expect(rack_session.values_at(session_key(:user), session_key(:admin_user)).uniq.size).
        to eq(2)
    end

    it 'lazily enrolls an authenticated legacy cookie without signing it out' do
      expect { enforce(user, scope: :user, event: :fetch) }.
        to change { user.authenticated_sessions.count }.by(1)

      expect(user.authenticated_sessions.last!.authentication_kind).to eq('legacy')
      expect(rack_session[session_key(:user)]).to be_present
      expect(warden).not_to have_received(:logout)
    end

    it 'enrolls the administrator first when a legacy cookie clearly represents Become' do
      allow(warden).to receive(:user).with(:admin_user).and_return(admin_user)
      allow(warden).to receive(:user).
        with(scope: :admin_user, run_callbacks: false).
        and_return(admin_user)

      enforce(user, scope: :user, event: :fetch)

      admin_session = admin_user.authenticated_sessions.last!
      impersonation = user.authenticated_sessions.last!
      expect(admin_session.authentication_kind).to eq('legacy')
      expect(impersonation.authentication_kind).to eq('admin_impersonation')
      expect(impersonation.initiated_by_authenticated_session).to eq(admin_session)
      expect(rack_session[session_key(:admin_user)]).to eq(admin_session.identifier)
    end

    it 'classifies explicit User OAuth as OAuth when an administrator scope coexists' do
      admin_session = admin_user.authenticated_sessions.first!
      allow(warden).to receive(:user).with(:admin_user).and_return(admin_user)
      allow(warden).to receive(:user).
        with(scope: :admin_user, run_callbacks: false).
        and_return(admin_user)
      rack_session[session_key(:admin_user)] = admin_session.identifier
      env['authenticated_session.authentication_kind.user'] = 'google_oauth'

      enforce(user, scope: :user, event: :set_user)

      expect(user.authenticated_sessions.last!.authentication_kind).to eq('google_oauth')
      expect(user.authenticated_sessions.last!.initiated_by_authenticated_session).to eq(nil)
    end

    it 'rejects a missing identified session without reenrolling it' do
      rack_session[session_key(:user)] = SecureRandom.urlsafe_base64(32)

      expect { expect_rejection { enforce(user, scope: :user, event: :fetch) } }.
        not_to change { AuthenticatedSession.count }
    end

    it 'rejects a revoked identified session without reenrolling it' do
      authenticated_session = create(
        :authenticated_session,
        authenticatable: user,
        revoked_at: Time.current,
      )
      rack_session[session_key(:user)] = authenticated_session.identifier

      expect { expect_rejection { enforce(user, scope: :user, event: :fetch) } }.
        not_to change { AuthenticatedSession.count }
    end

    it 'rejects an identifier belonging to another account' do
      other_user_session = create(
        :authenticated_session,
        authenticatable: User.excluding(user).first!,
      )
      rack_session[session_key(:user)] = other_user_session.identifier

      expect_rejection { enforce(user, scope: :user, event: :fetch) }
    end

    it 'rejects an identifier belonging to another Warden scope' do
      admin_session = admin_user.authenticated_sessions.first!
      rack_session[session_key(:user)] = admin_session.identifier

      expect_rejection { enforce(user, scope: :user, event: :fetch) }
    end

    it 'rejects an impersonation whose administrator parent has been revoked' do
      parent = create(
        :authenticated_session,
        :admin,
        authenticatable: admin_user,
        revoked_at: Time.current,
      )
      impersonation = create(
        :authenticated_session,
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: parent,
      )
      allow(warden).to receive(:user).with(:admin_user).and_return(admin_user)
      allow(warden).to receive(:user).
        with(scope: :admin_user, run_callbacks: false).
        and_return(admin_user)
      rack_session[session_key(:admin_user)] = parent.identifier
      rack_session[session_key(:user)] = impersonation.identifier

      expect_rejection { enforce(user, scope: :user, event: :fetch) }
    end

    it 'does not reject a valid User request when the optional AdminUser session is revoked' do
      user_session = user.authenticated_sessions.first!
      admin_session = admin_user.authenticated_sessions.first!
      admin_session.revoke!
      rack_session[session_key(:user)] = user_session.identifier
      rack_session[session_key(:admin_user)] = admin_session.identifier
      allow(warden).to receive(:user).
        with(scope: :user, run_callbacks: false).
        and_return(user)

      expect { enforce(admin_user, scope: :admin_user, event: :fetch) }.
        not_to throw_symbol(:warden)
      expect(warden).to have_received(:logout).with(:admin_user)
    end

    it 'does not reject a valid AdminUser request when the optional User session is revoked' do
      user_session = user.authenticated_sessions.first!
      admin_session = admin_user.authenticated_sessions.first!
      user_session.revoke!
      rack_session[session_key(:user)] = user_session.identifier
      rack_session[session_key(:admin_user)] = admin_session.identifier
      allow(warden).to receive(:user).
        with(scope: :admin_user, run_callbacks: false).
        and_return(admin_user)

      expect { enforce(user, scope: :user, event: :fetch) }.
        not_to throw_symbol(:warden)
      expect(warden).to have_received(:logout).with(:user)
    end
  end

  describe '.revoke_for_logout' do
    it 'revokes the represented session and clears its identifier' do
      authenticated_session = user.authenticated_sessions.first!
      rack_session[session_key(:user)] = authenticated_session.identifier

      described_class.revoke_for_logout(user, warden, scope: :user)

      expect(authenticated_session.reload).not_to be_active
      expect(rack_session).not_to have_key(session_key(:user))
    end
  end

  describe '.create_impersonation!' do
    before { allow(warden).to receive(:user).with(:admin_user).and_return(admin_user) }

    it 'replaces the User scope with a child of the exact active administrator session' do
      admin_user.update!(email: user.email)
      parent = admin_user.authenticated_sessions.first!
      previous_user_session = user.authenticated_sessions.first!
      rack_session[session_key(:admin_user)] = parent.identifier
      rack_session[session_key(:user)] = previous_user_session.identifier

      impersonation = described_class.create_impersonation!(user:, warden:)

      expect(previous_user_session.reload).not_to be_active
      expect(impersonation.authentication_kind).to eq('admin_impersonation')
      expect(impersonation.authenticatable).to eq(user)
      expect(impersonation.initiated_by_authenticated_session).to eq(parent)
    end

    it 'rejects a revoked administrator parent' do
      parent = create(
        :authenticated_session,
        :admin,
        authenticatable: admin_user,
        revoked_at: Time.current,
      )
      rack_session[session_key(:admin_user)] = parent.identifier

      expect { described_class.create_impersonation!(user:, warden:) }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  private

  def enforce(authenticatable, options)
    described_class.enforce!(authenticatable, warden, options)
  end

  def expect_rejection
    result =
      catch(:warden) do
        yield
        :not_rejected
      end

    expect(result).to include(scope: :user, action: :unauthenticated)
    expect(warden).to have_received(:logout).with(:user)
    expect(rack_session).not_to have_key(session_key(:user))
  end

  def session_key(scope)
    described_class.session_key(scope)
  end
end
