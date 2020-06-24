# frozen_string_literal: true

RSpec.describe LogEntriesMailbox do
  let(:to_email) { "log-entries|log/#{log.id}@mg.davidrunger.com" }
  let(:user) { users(:user) }
  let(:log) { user.logs.number.first! }

  describe 'routing' do
    it 'routes email to the mailbox' do
      expect(LogEntriesMailbox).to receive_email(to: to_email)
    end
  end

  describe 'processing' do
    subject(:processed_mail) { process(mail) }

    let(:mail) do
      Mail.new(
        to: to_email,
        from: user.email,
        subject: %(Re: Submit a log entry for your "#{log.name}" log),
        body: body,
      )
    end
    let(:body) { '148.8' }

    it 'marks email as delivered' do
      expect(processed_mail).to have_been_delivered
    end

    it 'creates a new log entry with the email body as the data' do
      processed_mail

      last_log_entry = log.log_entries.order(:created_at).last!
      expect(last_log_entry.data).to eq(Float(body))
    end

    it 'broadcasts the creation of the new log entry', :action_cable_test_adapter do
      expect { processed_mail }.
        to broadcast_to(LogEntriesChannel.broadcasting_for(log)).
        with(hash_including(data: Float(body)))
    end
  end
end
