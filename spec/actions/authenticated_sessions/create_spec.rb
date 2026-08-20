RSpec.describe AuthenticatedSessions::Create do
  subject(:action) do
    described_class.new!(
      authenticatable: user,
      authentication_kind:,
      request:,
      initiated_by_authenticated_session: nil,
    )
  end

  let(:user) { users(:user) }
  let(:authentication_kind) { 'google_oauth' }
  let(:request) do
    ActionDispatch::Request.new(
      'REMOTE_ADDR' => observed_ip,
      'HTTP_USER_AGENT' => observed_user_agent,
    )
  end
  let(:observed_ip) { Faker::Internet.ip_v4_address }
  let(:observed_user_agent) { 'Test Browser/1.0' }

  describe '#run!' do
    subject(:run!) { action.run! }

    it 'creates an AuthenticatedSession and enqueues an IP info fetch' do
      expect { run! }.to change { user.authenticated_sessions.count }.by(1)

      authenticated_session = user.authenticated_sessions.last!
      expect(authenticated_session.attributes).to include(
        'authentication_kind' => authentication_kind,
        'initial_ip' => observed_ip,
        'latest_ip' => observed_ip,
        'initial_user_agent' => observed_user_agent,
        'latest_user_agent' => observed_user_agent,
      )
      expect(FetchIpInfoForRecord).
        to have_enqueued_sidekiq_job.
        with('AuthenticatedSession', authenticated_session.id)
    end
  end
end
