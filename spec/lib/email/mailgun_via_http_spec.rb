# frozen_string_literal: true

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
        # https://github.com/bblimke/webmock/issues/ 623#issuecomment-536603971
        request.body.force_encoding('BINARY')
        request.body.include?('attached a zip file')
      end.to_return(
        status: 200,
        body: '',
        headers: {},
      )
    end

    before do
      expect(Rails.application.credentials).to receive(:mailgun!).
        and_return(api_key: stubbed_mailgun_api_key)
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
  end
end
