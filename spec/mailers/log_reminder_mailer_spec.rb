# frozen_string_literal: true

RSpec.describe LogReminderMailer do
  describe '#reminder' do
    subject(:mail) { LogReminderMailer.reminder(log.id) }

    let(:log) { logs(:number_log) }

    it 'is sent from log-reminders@davidrunger.com' do
      expect(mail.from).to eq(['log-reminders@davidrunger.com'])
    end

    it 'is sent to the owning user' do
      expect(mail.to).to eq([log.user.email])
    end

    it 'has a subject that says to submit a log entry' do
      expect(mail.subject).to eq(%(Submit a log entry for your "#{log.name}" log))
    end

    it 'has a reply-to that will create a new log entry' do
      expect(mail.reply_to).to eq(["log-entries|log/#{log.id}@mg.davidrunger.com"])
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'says that the user can create a log entry by replying to the email' do
        expect(body).to include(<<~TIP)
          <b>Tip:</b>
          To create a log entry, you can simply reply to this email with the desired log entry content.
        TIP
      end
    end
  end
end
