RSpec.describe Email::MailgunViaHttp do
  include MailSpecHelpers

  subject(:mailgun_via_http) { Email::MailgunViaHttp.new({}) }

  describe '#deliver!' do
    subject(:deliver!) { mailgun_via_http.deliver!(mail) }

    let(:mail) { mail_from_raw_email_fixture('body_and_attachment') }
    let(:stubbed_mailgun_api_key) { '2a4d89d1-1984-4453-8ea5-2468d1769a6c' }
    let!(:mailgun_http_request) do
      stub_request(
        :post,
        'https://api.mailgun.net/v3/mg.davidrunger.com/messages',
      ).with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Basic YXBpOjJhNGQ4OWQxLTE5ODQtNDQ1My04ZWE1LTI0NjhkMTc2OWE2Yw==',
          'Content-Type' =>
            %r{multipart/form-data; boundary=-----------RubyMultipartPost-[0-9a-f]{32}},
          'User-Agent' => /Faraday v\d+\.\d+\.\d+/,
        },
      ) do |request|
        # https://github.com/bblimke/webmock/issues/623#issuecomment-536603971
        request.body.force_encoding('BINARY')
        request.body.include?('attached a zip file')
      end.to_return(
        status: 200,
        body: '',
        headers: {},
      )
    end

    context 'when there is a valid MAILGUN_API_KEY env var' do
      around do |spec|
        ClimateControl.modify(MAILGUN_API_KEY: stubbed_mailgun_api_key) do
          spec.run
        end
      end

      it 'makes an HTTP POST request to the appropriate Mailgun URL' do
        deliver!

        expect(mailgun_http_request).to have_been_requested
      end

      context 'when the `log_mailgun_http_response` flag is enabled' do
        before { activate_feature!(:log_mailgun_http_response) }

        it 'logs info about the Mailgun HTTP response' do
          expect(Rails.logger).
            to receive(:info).
            with(/Mailgun response for email.* status=.* body=.* headers=/).
            and_call_original

          deliver!
        end
      end
    end
  end

  describe '#post_body' do
    subject(:post_body) { mailgun_via_http.send(:post_body, mail) }

    context 'when the mail body is empty' do
      before do
        expect(mail).to receive(:body).and_return(instance_double(Mail::Body, to_s: ''))
        expect(mail).to receive(:has_attachments?).and_return(false)
      end

      let(:mail) { mail_from_raw_email_fixture('empty_body') }

      it 'returns a hash with default empty HTML tags for the :html key' do
        expect(post_body[:html]).to eq('<div></div>')
      end
    end

    context 'when an attachment filename contains path traversal' do
      let(:attachment_filename) { '../../../../app/views/malicious.html.haml' }
      let(:mail) do
        Mail.new.tap do |message|
          message.from = 'sender@example.com'
          message.to = 'davidjrunger@gmail.com'
          message.subject = 'Attachment'
          message.add_file(filename: attachment_filename, content: 'safe content')
        end
      end

      it 'uploads the attachment from memory with a sanitized display filename' do
        file_part = post_body.fetch(:attachment).sole

        expect(file_part.original_filename).to eq('malicious.html.haml')
        expect(file_part.io).to be_a(StringIO)
        expect(file_part.io.string).to eq('safe content')
        expect(file_part.local_path).to eq('local.path')
      end
    end
  end

  describe '#safe_to_value' do
    subject(:safe_to_value) { mailgun_via_http.send(:safe_to_value, mail) }

    context 'when Rails.env is "development"', rails_env: :development do
      context 'when the recpient is davidrunger@gmail.com' do
        let(:mail) { mail_from_raw_email_fixture('body_and_attachment') }

        it 'returns davidjrunger@gmail.com' do
          expect(safe_to_value).to eq('David Runger <davidjrunger@gmail.com>')
        end
      end

      context 'when the recpient is not davidrunger@gmail.com' do
        let(:mail) { mail_from_raw_email_fixture('empty_body') }

        it 'raises an error' do
          expect { safe_to_value }.to raise_error(
            'You *actually* tried to send an email to ["reply@mg.davidrunger.com"]!',
          )
        end
      end
    end

    context 'when Rails.env is "production"', rails_env: :production do
      context 'when the recpient is not davidrunger@gmail.com' do
        let(:mail) { mail_from_raw_email_fixture('empty_body') }

        it 'returns the email' do
          expect(safe_to_value).to eq('"DavidRunger.com" <reply@mg.davidrunger.com>')
        end
      end
    end
  end
end
