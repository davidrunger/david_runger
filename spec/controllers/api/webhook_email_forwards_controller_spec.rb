RSpec.describe Api::WebhookEmailForwardsController do
  describe '#create' do
    subject(:post_create) do
      post(:create, params:)
    end

    let(:params) { {} }

    context 'when the request includes a valid AuthToken secret' do
      before { request.headers['Authorization'] = "Bearer #{auth_token.secret}" }

      let(:auth_token) { AuthToken.first! }

      context 'when the request params include a "title" and "message"' do
        let(:params) do
          super().merge({
            'title' => alert_title,
            'message' => alert_body,
          })
        end
        let(:alert_title) { 'CPU usage is high!' }
        let(:alert_body) { '<html><head></head><body><p>CPU problem!</p></body></html>' }

        it 'sends an HTML email to the AuthToken user with the title as the subject and the message as the body' do
          with_inline_sidekiq do
            post_create
          end

          # Check that email was sent with expected properties.
          expect(ActionMailer::Base.deliveries.size).to eq(1)
          mail = ActionMailer::Base.deliveries.first
          expect(mail.content_type).to eq('text/html; charset=UTF-8')
          expect(mail.to).to eq([auth_token.user.email])
          expect(mail.subject).to eq(alert_title)
          expect(mail.body.to_s).to eq(alert_body)
        end
      end
    end
  end
end
