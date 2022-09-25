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
      Mail.new(to: to_email, from: from_email, subject: email_subject, body: email_body)
    end

    it 'marks email as delivered' do
      expect(processed_mail).to have_been_delivered
    end

    it 'triggers a ReplyForwardingMailer#reply_received email to be sent', queue_adapter: :test do
      expect { processed_mail }.to enqueue_mail(ReplyForwardingMailer, :reply_received).
        with(String, from_email, email_subject, email_body, false, false) { |message_id, _, _, _, _|
          expect(message_id).to eq(mail.message_id)
        }
    end

    context 'when an error is raised while parsing the email body' do
      before do
        expect(EmailReplyTrimmer).
          to receive(:trim).
          and_raise(ArgumentError, 'invalid byte sequence in UTF-8')
      end

      it 'sends an error to Rollbar' do
        expect(Rollbar).to receive(:error).with(
          instance_of(ArgumentError),
          from_email:,
          subject: email_subject,
          body: email_body,
        ).and_call_original

        processed_mail
      end

      it 'sends the email with a body indicating an error occurred', queue_adapter: :test do
        expect { processed_mail }.to enqueue_mail(ReplyForwardingMailer, :reply_received).
          with(String, from_email, email_subject, '[error reading parsed body]', false, false)
      end
    end

    context 'when the email has an attachment' do
      subject(:route_mail) do
        create_inbound_email_from_source(mail.to_s, status: :processing).tap(&:route)
      end

      before do
        # https://gorails.com/forum/how-to-test-attachments-in-actionmailbox
        mail.add_file(filename: 'sample.txt', content: StringIO.new('Sample Logo'))
      end

      it 'triggers a ReplyForwardingMailer#reply_received email to be sent', queue_adapter: :test do
        expect { route_mail }.to enqueue_mail(ReplyForwardingMailer, :reply_received).
          with(
            String,
            from_email,
            email_subject,
            email_body,
            false,
            true,
          ) { |message_id, _, _, _, _|
            expect(message_id).to eq(mail.message_id)
          }
      end
    end

    context 'when the email is just an attachment' do
      subject(:route_mail) { route_raw_email_fixture('attachment_only') }

      it 'triggers a ReplyForwardingMailer#reply_received email to be sent', queue_adapter: :test do
        expect { route_mail }.to enqueue_mail(ReplyForwardingMailer, :reply_received).
          with(
            '15113626491834982726@google.com',
            'noreply-dmarc-support@google.com',
            'Report domain: davidrunger.com Submitter: google.com Report-ID: 15113626491834982726',
            '[no body (just an attachment)]',
            true,
            false,
          )
      end
    end
  end
end
