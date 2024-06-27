# frozen_string_literal: true

RSpec.describe AdminMailer do
  describe '#broken_link' do
    subject(:mail) do
      AdminMailer.broken_link(
        url,
        page_source_url,
        status,
        expected_statuses,
      )
    end

    let(:url) { 'https://app.codecov.io/gh/davidrunger/david_runger' }
    let(:page_source_url) { 'https://davidrunger.com/' }
    let(:status) { 500 }
    let(:expected_statuses) { [200] }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has a subject that says there is a problem with a home link' do
      expect(mail.subject).to eq("Link to #{url} did not return expected status")
    end

    it 'has reply@mg.davidrunger.com as the reply-to' do
      expect(mail.reply_to).to eq(['reply@mg.davidrunger.com'])
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'says the URL, the unexpected response status, and expected statuses' do
        expect(body).to have_text("We made a request to #{url}")
        expect(body).to have_text("its response status was #{status}")
        expect(body).to have_text("we expected it to be in #{expected_statuses}")
      end

      context 'when the status is nil' do
        let(:status) { nil }

        it 'says the URL, where it is linked, and what the unexpected response status was' do
          expect(body).to have_text(<<~TEXT.squish)
            We made a request to https://app.codecov.io/gh/davidrunger/david_runger,
            which is linked from https://davidrunger.com/,
            and its response status was nil
          TEXT
        end
      end
    end
  end

  describe '#user_created' do
    subject(:mail) { AdminMailer.user_created(new_user.id) }

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

      it 'says that there is a new user' do
        expect(body).to include("A new user has been created with email #{new_user.email}!")
      end
    end
  end
end
