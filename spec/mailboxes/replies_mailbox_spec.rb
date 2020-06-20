# frozen_string_literal: true

RSpec.describe RepliesMailbox do
  let(:to_email) { 'reply@mg.davidrunger.com' }
  let(:from_email) { user.email }
  let(:user) { users(:user) }
  let(:email_subject) { 'Great website!!!' }
  let(:email_body) { 'I just want to let you know that your website is great!' }

  describe 'routing' do
    it 'routes email to the mailbox' do
      expect(RepliesMailbox).to receive_email(to: to_email)
    end
  end

  describe 'processing' do
    subject(:processed_mail) { process(mail) }

    let(:mail) do
      Mail.new(
        to: to_email,
        from: from_email,
        subject: email_subject,
        body: email_body,
      )
    end

    it 'marks email as delivered' do
      expect(processed_mail).to have_been_delivered
    end

    it 'triggers a ReplyForwardingMailer#reply_received email to be sent', queue_adapter: :test do
      expect { processed_mail }.to enqueue_mail(ReplyForwardingMailer, :reply_received).
        with(args: [from_email, email_subject, email_body])
    end
  end
end
