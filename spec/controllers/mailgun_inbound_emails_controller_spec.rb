RSpec.describe MailgunInboundEmailsController do
  let(:rate_limit_cache_key) { 'rate-limit:mailgun_inbound_emails:all' }

  around do |example|
    MailgunInboundEmailsController.cache_store.delete(rate_limit_cache_key)
    ActionMailbox.with(ingress: :mailgun) do
      example.run
    end
  ensure
    MailgunInboundEmailsController.cache_store.delete(rate_limit_cache_key)
  end

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:params) { { 'body-mime' => mail.to_s } }
    let(:mail) do
      Mail.new(
        to: 'reply@mg.davidrunger.com',
        from: 'sender@example.com',
        subject: 'Hello',
        body: 'Hello from Mailgun',
      )
    end

    context 'when the request is not authenticated by Mailgun' do
      before { allow(controller).to receive(:authenticated?).and_return(false) }

      it 'rejects the request before consuming an ingress rate-limit token' do
        expect(controller).not_to receive(:rate_limiting)

        post_create

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the request is authenticated by Mailgun' do
      before { allow(controller).to receive(:authenticated?).and_return(true) }

      context 'when the ingress rate limit has not been reached' do
        before do
          expect(MailgunInboundEmailsController.cache_store.read(rate_limit_cache_key)).to be_nil
        end

        it 'consumes an ingress rate-limit token before storing the email' do
          expect(controller).to receive(:rate_limiting).and_call_original
          expect { post_create }.to change { ActionMailbox::InboundEmail.count }.by(1)

          expect(response).to have_http_status(:no_content)
        end
      end

      context 'when the ingress rate limit has been reached' do
        before do
          MailgunInboundEmailsController.cache_store.increment(
            rate_limit_cache_key,
            MailgunInboundEmailsController::REQUEST_LIMIT,
            expires_in: 1.day,
          )
        end

        it 'rejects the request without storing the email' do
          expect(Rails.error).
            to receive(:report).
            with(
              an_object_having_attributes(
                backtrace: an_instance_of(Array),
                class: MailgunInboundEmailsController::IngressRateLimitReached,
                message: 'Mailgun inbound email rate limit reached.',
              ),
              severity: :warning,
              context: { request_limit: 100 },
            ).
            and_call_original

          expect { post_create }.not_to change { ActionMailbox::InboundEmail.count }

          expect(response).to have_http_status(:too_many_requests)
        end
      end
    end
  end
end
