# frozen_string_literal: true

RSpec.describe LogShareMailer do
  describe '#log_shared' do
    subject(:mail) { LogShareMailer.log_shared(log_share.id) }

    let(:log_share) { LogShare.first! }
    let(:sharee_email) { log_share.email }
    let(:shared_log) { log_share.log }
    let(:sharing_user) { shared_log.user }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to the sharee' do
      expect(mail.to).to eq([sharee_email])
    end

    it 'has a subject that names the shared log and says that it has been shared' do
      expect(mail.subject).to eq(
        %(#{sharing_user.email} shared their "#{shared_log.name}" log with you),
      )
    end

    it 'has reply@mg.davidrunger.com as the reply-to' do
      expect(mail.reply_to).to eq(['reply@mg.davidrunger.com'])
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'has a link to the shared log' do
        expect(body).to include(%(View #{sharing_user.email}'s #{shared_log.name} log here:))
        expect(body).to include(
          user_shared_log_url(
            user_id: sharing_user.id,
            slug: shared_log.slug,
          ),
        )
      end
    end
  end
end
