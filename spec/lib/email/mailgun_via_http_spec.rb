# frozen_string_literal: true

RSpec.describe Email::MailgunViaHttp do
  subject(:mailgun_via_http) { Email::MailgunViaHttp.new({}) }

  describe '#deliver!' do
    subject(:deliver!) { mailgun_via_http.deliver!(mail) }

    let(:mail) do
      instance_double(
        ::Mail::Message,
        subject: subject,
        body: email_body,
        to: [ugly_to_email], # this stub is a bit misleading; `#to` doesn't return an array
        from: [ugly_from_email], # this stub is a bit misleading; `#from` doesn't return an array
        reply_to: [reply_to_email],
      )
    end
    let(:subject) { "There's a new davidrunger.com user! :) Email: davidjrunger@gmail.com." }
    let(:email_body) { 'A new user has been created with email davidjrunger@gmail.com!' }
    let(:ugly_from_email) { 'reply@davidrunger.com' }
    let(:ugly_to_email) { 'davidjrunger@gmail.com' }
    let(:pretty_from_email) { %("DavidRunger.com" <#{ugly_from_email}>) }
    let(:pretty_to_email) { %("David Runger" <#{ugly_to_email}>) }
    let(:reply_to_email) { '"DavidRunger.com" <reply@mg.davidrunger.com>' }
    let(:stubbed_mailgun_api_key) { '2a4d89d1-1984-4453-8ea5-2468d1769a6c' }
    let!(:mailgun_http_request) do
      stub_request(
        :post,
        'https://api.mailgun.net/v3/mg.davidrunger.com/messages',
      ).with(
        body: HTTParty::HashConversions.to_params(
          from: pretty_from_email,
          to: pretty_to_email,
          subject: subject,
          html: email_body,
          'h:Reply-To' => reply_to_email,
        ),
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Basic YXBpOjJhNGQ4OWQxLTE5ODQtNDQ1My04ZWE1LTI0NjhkMTc2OWE2Yw==',
          'User-Agent' => 'Ruby',
        },
      ).to_return(
        status: 200,
        body: '',
        headers: {},
      )
    end

    before do
      expect(ENV).to receive(:[]).at_least(:once).with('MAILGUN_URL').
        and_return('https://api.mailgun.net/v3/mg.davidrunger.com')
      expect(ENV).to receive(:[]).at_least(:once).with('MAILGUN_API_KEY').
        and_return(stubbed_mailgun_api_key)
      allow(ENV).to receive(:[]).and_call_original # pass other calls through

      expect(mail).to receive(:[]).at_least(:once) do |key|
        if key == 'From'
          pretty_from_email
        elsif key == 'To'
          pretty_to_email
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
