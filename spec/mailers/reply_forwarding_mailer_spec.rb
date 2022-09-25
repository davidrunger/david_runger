# frozen_string_literal: true

RSpec.describe ReplyForwardingMailer do
  describe '#reply_received' do
    subject(:mail) do
      ReplyForwardingMailer.reply_received(
        message_id,
        from_email,
        email_subject,
        email_body,
        is_attachment,
        has_attachments,
      )
    end

    let(:user) { users(:user) }
    let(:message_id) { SecureRandom.alphanumeric }
    let(:from_email) { user.email }
    let(:email_subject) { 'Great website!!!' }
    let(:email_body) { 'I just want to let you know that your website is great!' }
    let(:is_attachment) { false }
    let(:has_attachments) { false }

    it 'is sent from noreply@davidrunger.com' do
      expect(mail.from).to eq(['noreply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has no reply-to' do
      expect(mail.reply_to).to eq(nil)
    end

    it "has a subject that includes the subject from the user's email and their email address" do
      expect(mail.subject).to include(email_subject)
      expect(mail.subject).to include(from_email)
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it "includes the body from the user's email" do
        expect(body).to include(email_body)
      end
    end

    context 'when there are attachments' do
      let(:has_attachments) { true }

      before do
        inbound_email = ActionMailbox::InboundEmail.create!(
          message_id:,
          message_checksum: '91cabu12',
        )
        blob = inbound_email.create_raw_email_blob!(
          checksum: 'colb234u',
          filename: 'a_file.txt',
          byte_size: 298,
        )
        inbound_email.create_raw_email_attachment!(blob:, content_type: 'text/plain')

        # rubocop:disable RSpec/AnyInstance
        expect_any_instance_of(ActiveStorage::Blob).to receive(:download).and_return(
          "Date: Sat, 24 Sep 2022 22:08:43 -0500\r\nFrom: davidjrunger@gmail.com\r\nTo: " \
          'reply@mg.davidrunger.com\r\nMessage-ID: ' \
          "<7291c2ba3679_126b3616c51155@server.local.mail>\r\nIn-Reply-To: \r\n" \
          "Subject: Attachment Subject\r\nMime-Version: 1.0\r\nContent-Type: multipart/mixed;" \
          "\r\n boundary=\"--==_mimepart_7291c2b9a328_126b3616c510df\"\r\n" \
          "Content-Transfer-Encoding: 7bit\r\nx-original-to: \r\n\r\n\r\n" \
          "----==_mimepart_7291c2b9a328_126b3616c510df\r\nContent-Type: text/plain;\r\n " \
          "charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\nattachment body\r\n" \
          "----==_mimepart_7291c2b9a328_126b3616c510df\r\nContent-Type: text/plain;\r\n " \
          "charset=UTF-8;\r\n filename=random.txt\r\nContent-Transfer-Encoding: 7bit\r\n" \
          "Content-Disposition: attachment;\r\n filename=random.txt\r\n\r\nAttachment content." \
          "\r\n\r\n----==_mimepart_7291c2b9a328_126b3616c510df--\r\n",
        )
        # rubocop:enable RSpec/AnyInstance
      end

      it 'includes the attachments' do
        expect(mail.attachments.size).to eq(1)
      end
    end

    context 'when the forwarded email is just an attachment' do
      before { route_raw_email_fixture('attachment_only') }

      let(:message_id) { '15113626491834982726@google.com' }
      let(:email_body) { '[no body (just an attachment)]' }
      let(:is_attachment) { true }
      let(:has_attachments) { false }

      it 'says that there is no email body' do
        expect(mail.message.encoded).to include(email_body)
      end

      it 'includes the attachment' do
        expect(mail.attachments.size).to eq(1)
      end
    end
  end
end
