RSpec.describe LogEntriesMailbox do
  let(:to_email) { "log-entries|log/#{log.email_submission_token}@mg.davidrunger.com" }
  let(:user) { users(:user) }
  let(:log) { user.logs.number.first! }

  describe 'routing' do
    it 'routes email to the mailbox' do
      expect(LogEntriesMailbox).to receive_email(to: to_email)
    end

    it 'does not route email addressed with an enumerable log ID' do
      expect(LogEntriesMailbox).not_to receive_email(
        to: "log-entries|log/#{log.id}@mg.davidrunger.com",
      )
    end
  end

  describe 'processing' do
    subject(:processed_mail) { process(mail) }

    let(:mail) do
      Mail.new(
        to: to_email,
        from: from_email,
        subject: %(Re: Submit a log entry for your "#{log.name}" log),
        body:,
      )
    end
    let(:body) { '148.8' }
    let(:from_email) { user.email }

    it 'marks email as delivered' do
      expect(processed_mail).to have_been_delivered
    end

    it 'creates a new log entry with the email body as the data' do
      processed_mail

      last_log_entry = log.log_entries.order(:created_at).last!
      expect(last_log_entry.data).to eq(Float(body))
    end

    it 'authorizes the log by the recipient token and From address' do
      expect { processed_mail }.to change { log.log_entries.count }.by(1)
    end

    it 'broadcasts the creation of the new log entry', :action_cable_test_adapter do
      expect { processed_mail }.
        to broadcast_to(LogEntriesChannel.broadcasting_for(log)).
        with(hash_including(model: hash_including(data: Float(body))))
    end

    context 'when the From address does not belong to the log owner' do
      let(:from_email) { User.excluding(user).first!.email }

      it 'delivers the email without creating a log entry' do
        expect { processed_mail }.not_to(change { LogEntry.count })
        expect(processed_mail).to have_been_delivered
      end
    end

    context 'when the email submission token is not recognized' do
      let(:to_email) do
        unknown_token = '0' * Log::EMAIL_SUBMISSION_TOKEN_LENGTH

        "log-entries|log/#{unknown_token}@mg.davidrunger.com"
      end

      it 'delivers the email without creating a log entry' do
        expect { processed_mail }.not_to(change { LogEntry.count })
        expect(processed_mail).to have_been_delivered
      end
    end
  end
end
