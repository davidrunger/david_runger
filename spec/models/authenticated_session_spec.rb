RSpec.describe AuthenticatedSession do
  subject(:authenticated_session) { user.authenticated_sessions.first! }

  let(:user) { users(:user) }

  it 'generates a unique, cryptographically random identifier' do
    identifiers = Array.new(2) { create(:authenticated_session).identifier }

    expect(identifiers).to all(match(/\A[A-Za-z0-9]{24}\z/))
    expect(identifiers.uniq.size).to eq(2)
  end

  it 'belongs polymorphically to Users and AdminUsers' do
    user_session = authenticated_session
    admin_session = create(:authenticated_session, :admin)

    expect(user_session.authenticatable).to be_a(User)
    expect(admin_session.authenticatable).to be_a(AdminUser)
  end

  it 'rejects missing and empty User-Agent values' do
    authenticated_session = build(:authenticated_session, initial_user_agent: nil)
    expect(authenticated_session).not_to be_valid

    authenticated_session.initial_user_agent = ''
    authenticated_session.latest_user_agent = ''

    expect(authenticated_session).not_to be_valid
    expect(authenticated_session.errors).to include(:initial_user_agent, :latest_user_agent)
  end

  describe 'impersonation validation' do
    it 'requires a parent session' do
      impersonation = build(
        :authenticated_session,
        authentication_kind: 'admin_impersonation',
      )

      expect(impersonation).not_to be_valid
      expect(impersonation.errors[:initiated_by_authenticated_session_id]).
        to include("can't be blank")
    end

    it 'requires an AdminUser parent and disallows nested impersonation' do
      user_parent = create(:authenticated_session)
      admin_parent = create(:authenticated_session, :admin)
      impersonation = build(
        :authenticated_session,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: user_parent,
      )

      expect(impersonation).not_to be_valid

      impersonation.initiated_by_authenticated_session = admin_parent
      expect(impersonation).to be_valid

      admin_parent = create(
        :authenticated_session,
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: admin_parent,
      )
      impersonation.initiated_by_authenticated_session = admin_parent
      expect(impersonation).not_to be_valid
    end

    it 'revokes active impersonation children when their administrator parent is revoked' do
      parent = create(:authenticated_session, :admin)
      child = create(
        :authenticated_session,
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: parent,
      )

      parent.revoke!

      expect(parent.reload).not_to be_active
      expect(child.reload).not_to be_active
    end

    it 'destroys impersonation children when their administrator parent is destroyed' do
      parent = create(:authenticated_session, :admin)
      child = create(
        :authenticated_session,
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: parent,
      )

      expect { parent.destroy! }.
        to change { AuthenticatedSession.where(id: [parent.id, child.id]).count }.
        from(2).
        to(0)
    end

    it 'destroys impersonation children when their AdminUser is destroyed' do
      admin_user = create(:admin_user)
      parent = create(:authenticated_session, :admin, authenticatable: admin_user)
      child = create(
        :authenticated_session,
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        initiated_by_authenticated_session: parent,
      )

      expect { admin_user.destroy! }.
        to change { AuthenticatedSession.where(id: [parent.id, child.id]).count }.
        from(2).
        to(0)
    end
  end

  describe '#revoke!' do
    it 'disconnects only the Action Cable connection for that User session' do
      remote_connections = instance_double(ActionCable::RemoteConnections)
      remote_connection = instance_double(
        ActionCable::RemoteConnections::RemoteConnection,
        disconnect: true,
      )
      allow(ActionCable.server).to receive(:remote_connections).and_return(remote_connections)
      allow(remote_connections).to receive(:where).and_return(remote_connection)

      authenticated_session.revoke!

      expect(remote_connections).to have_received(:where).with(
        authenticated_session_identifier: authenticated_session.identifier,
        current_user: user,
      )
      expect(remote_connection).to have_received(:disconnect).once
    end
  end

  describe '#record_activity!' do
    let(:observed_ip) { Faker::Internet.ip_v4_address }
    let(:request) do
      instance_double(ActionDispatch::Request, remote_ip: observed_ip, user_agent: 'New client')
    end

    it 'updates activity and latest metadata at most once in the current minute' do
      travel_to(Time.zone.parse('2026-08-13 12:34:10')) do
        authenticated_session.update!(last_active_at: 1.minute.ago.change(sec: 0, usec: 0))

        expect { authenticated_session.record_activity!(request) }.
          to change { authenticated_session.reload.last_active_at }
        first_updated_at = authenticated_session.updated_at

        travel 30.seconds
        authenticated_session.record_activity!(request)

        expect(authenticated_session.reload.updated_at).to eq(first_updated_at)
        expect(authenticated_session.last_active_at).to eq(Time.current.change(sec: 0, usec: 0))
        expect(authenticated_session.attributes.values_at('latest_ip', 'latest_user_agent')).
          to eq([observed_ip, 'New client'])
      end
    end

    it 'updates again after the minute changes without rounding into the future' do
      travel_to(Time.zone.parse('2026-08-13 12:34:59')) do
        authenticated_session.update!(last_active_at: 1.minute.ago.change(sec: 0, usec: 0))
        authenticated_session.record_activity!(request)
        travel 2.seconds

        expect { authenticated_session.record_activity!(request) }.
          to change { authenticated_session.reload.last_active_at }.
          to(Time.zone.parse('2026-08-13 12:35:00'))
      end
    end
  end

  describe 'PaperTrail retention', :versioning do
    it 'versions destruction but not creation, activity, or revocation' do
      request = instance_double(
        ActionDispatch::Request,
        remote_ip: Faker::Internet.ip_v4_address,
        user_agent: 'New client',
      )
      authenticated_session.update!(last_active_at: 2.minutes.ago)

      expect { authenticated_session.record_activity!(request) }.
        not_to change { PaperTrail::Version.count }
      expect { authenticated_session.revoke! }.
        not_to change { PaperTrail::Version.count }
      expect { authenticated_session.destroy! }.
        to change { PaperTrail::Version.where(item_type: 'AuthenticatedSession').count }.by(1)
    end

    it 'destroys sessions and retains destroy versions when an account is deleted' do
      authenticated_session

      expect { User.with_eager_loading_for_destroy.find(user.id).destroy! }.
        to change { PaperTrail::Version.where(item_type: 'AuthenticatedSession').count }.by(1)
      expect(AuthenticatedSession.where(id: authenticated_session.id)).not_to exist
    end

    it 'destroys an AdminUser session and retains its destroy version' do
      admin_user = create(:admin_user)
      admin_session = create(:authenticated_session, :admin, authenticatable: admin_user)

      expect { admin_user.destroy! }.
        to change { PaperTrail::Version.where(item_type: 'AuthenticatedSession').count }.by(1)
      expect(AuthenticatedSession.where(id: admin_session.id)).not_to exist
    end
  end
end
