# frozen_string_literal: true

RSpec.describe AdminMailer do
  describe '#user_created' do
    subject(:mail) { AdminMailer.bad_home_link(url, status, expected_status) }

    let(:url) { 'https://app.codecov.io/gh/davidrunger/david_runger' }
    let(:status) { 500 }
    let(:expected_status) { 200 }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has a subject that says there is a problem with a home link' do
      expect(mail.subject).to eq(
        "Home link to #{url} did not return expected status",
      )
    end

    it 'has reply@mg.davidrunger.com as the reply-to' do
      expect(mail.reply_to).to eq(['reply@mg.davidrunger.com'])
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'says the URL and what the unexpected response status was' do
        expect(body).to have_text(
          "We made a request to #{url} and its response status was #{status}",
        )
      end

      context 'when the status is nil' do
        let(:status) { nil }

        it 'says the URL and what the unexpected response status was (nil)' do
          expect(body).to have_text(
            "We made a request to #{url} and its response status was nil",
          )
        end
      end
    end
  end
end
