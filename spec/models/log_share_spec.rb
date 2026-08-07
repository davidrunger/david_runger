RSpec.describe LogShare do
  subject(:log_share) { log_shares(:log_share) }

  it { is_expected.to belong_to(:log) }

  it { is_expected.to validate_presence_of(:email) }

  describe 'email' do
    it 'normalizes whitespace and letter case' do
      log_share.email = '  Shared.User@Example.COM  '

      expect(log_share.email).to eq('shared.user@example.com')
    end

    it 'rejects an invalid email address' do
      log_share.email = 'not-an-email-address'

      expect(log_share).not_to be_valid
      expect(log_share.errors.full_messages_for(:email)).to eq(['Email is invalid'])
    end

    it 'leaves blank email addresses to presence validation' do
      log_share.email = ''

      expect(log_share).not_to be_valid
      expect(log_share.errors.full_messages_for(:email)).to eq(["Email can't be blank"])
    end

    it 'rejects a normalized duplicate for the same log' do
      duplicate_log_share =
        build(
          :log_share,
          log: log_share.log,
          email: "  #{log_share.email.upcase}  ",
        )

      expect(duplicate_log_share).not_to be_valid
      expect(duplicate_log_share.errors[:email]).to include('has already been taken')
    end
  end
end
