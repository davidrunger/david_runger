# frozen_string_literal: true

RSpec.describe NewUserMailer do
  describe '#user_created' do
    subject(:mail) { NewUserMailer.user_created(new_user.id) }

    let(:new_user) { users(:user) }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has a subject that says there is a new user and their email' do
      expect(mail.subject).to eq(
        "There's a new davidrunger.com user! :) Email: #{new_user.email}.",
      )
    end

    it 'has reply@mg.davidrunger.com as the reply-to' do
      expect(mail.reply_to).to eq(['reply@mg.davidrunger.com'])
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'says something' do
        expect(body).to include("A new user has been created with email #{new_user.email}!")
      end
    end
  end
end
