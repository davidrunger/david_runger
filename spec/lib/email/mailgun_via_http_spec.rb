# frozen_string_literal: true

RSpec.describe Email::MailgunViaHttp do
  subject(:mailgun_via_http) { Email::MailgunViaHttp.new({}) }

  describe '#deliver!' do
    subject(:deliver!) { mailgun_via_http.deliver!(mail) }

    let(:mail) do
      instance_double(
        ::Mail::Message,
        subject: email_subject,
        body: email_body,
        to: [ugly_to_email],
        from: [ugly_from_email],
        reply_to: [ugly_reply_to_email],
      )
    end
    let(:email_subject) { "There's a new davidrunger.com user! :) Email: davidjrunger@gmail.com." }
    let(:email_body) { 'A new user has been created with email davidjrunger@gmail.com!' }
    let(:ugly_from_email) { 'reply@davidrunger.com' }
    let(:pretty_from_email) { "DavidRunger.com <#{ugly_from_email}>" }
    let(:ugly_to_email) { 'davidjrunger@gmail.com' }
    let(:pretty_to_email) { "David Runger <#{ugly_to_email}>" }
    let(:ugly_reply_to_email) { 'reply@mg.davidrunger.com' }
    let(:pretty_reply_to_email) { "DavidRunger.com <#{ugly_reply_to_email}>" }
    let(:stubbed_mailgun_api_key) { '2a4d89d1-1984-4453-8ea5-2468d1769a6c' }
    let!(:mailgun_http_request) do
      stub_request(
        :post,
        'https://api.mailgun.net/v3/mg.davidrunger.com/messages',
      ).with(
        body: Faraday::NestedParamsEncoder.encode(
          to: pretty_to_email,
          subject: email_subject,
          from: pretty_from_email,
          'h:Reply-To' => pretty_reply_to_email,
          html: email_body,
        ),
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Basic YXBpOjJhNGQ4OWQxLTE5ODQtNDQ1My04ZWE1LTI0NjhkMTc2OWE2Yw==',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => /Faraday v\d+\.\d+\.\d+/,
        },
      ).to_return(
        status: 200,
        body: '',
        headers: {},
      )
    end

    around do |spec|
      ClimateControl.modify(
        MAILGUN_URL: 'https://api.mailgun.net/v3/mg.davidrunger.com',
        MAILGUN_API_KEY: stubbed_mailgun_api_key,
      ) do
        spec.run
      end
    end

    before do
      expect(mail).to receive(:[]).at_least(:once) do |key|
        case key
        when 'From' then pretty_from_email
        when 'To' then pretty_to_email
        when 'Subject' then email_subject
        when 'Reply-To' then pretty_reply_to_email
        else
          raise('Unexpected key accessed on mail object')
        end
      end
    end

    it 'makes an HTTP POST request to ENV["MAILGUN_URL"]' do
      deliver!

      expect(mailgun_http_request).to have_been_requested
    end
  end
end
