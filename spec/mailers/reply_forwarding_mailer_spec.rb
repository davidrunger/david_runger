# frozen_string_literal: true

RSpec.describe ReplyForwardingMailer do
  describe '#reply_received' do
    subject(:mail) { ReplyForwardingMailer.reply_received(from_email, email_subject, email_body) }

    let(:user) { users(:user) }
    let(:from_email) { user.email }
    let(:email_subject) { 'Great website!!!' }
    let(:email_body) { 'I just want to let you know that your website is great!' }

    it 'is sent from noreply@davidrunger.com' do
      expect(mail.from).to eq(['noreply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has no reply-to' do
      expect(mail.reply_to).to eq([])
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
  end
end
