RSpec.describe Api::LogSharesController, queue_adapter: :test do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:log) { user.logs.joins(:log_shares).first! }

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    context 'when the log share params are invalid' do
      let(:invalid_params) { { log_share: { email: nil, log_id: log.id } } }
      let(:params) { invalid_params }

      it 'returns a 422 status code' do
        expect {
          post_create
        }.not_to have_enqueued_mail(LogShareMailer, :log_shared)

        expect(response).to have_http_status(422)
      end
    end

    context 'when the log share params are valid' do
      let(:valid_params) do
        { log_share: { email: Faker::Internet.email, log_id: log.id } }
      end
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        expect { post_create }.to have_enqueued_mail(LogShareMailer, :log_shared)
        expect(response).to have_http_status(201)
      end

      it 'creates a log share' do
        expect { post_create }.to have_enqueued_mail(LogShareMailer, :log_shared)

        log_share = LogShare.order(:id).last!
        expect(log_share.email).to eq(params[:log_share][:email].downcase)
      end

      context 'when the email delivery limit is reached' do
        before do
          Email::UserGeneratedDeliveryLimiter::RECIPIENT_HOUR_LIMIT.maximum.times do
            actor = create(:user)
            Email::UserGeneratedDeliveryLimiter.reserve(
              actor:,
              recipient_email: params[:log_share][:email],
              category: :log_share,
            )
          end
        end

        it 'retains the log share and reports that no email was sent' do
          expect {
            post_create
          }.to have_enqueued_mail(LogShareMailer, :log_shared).exactly(0).times

          expect(response).to have_http_status(:created)
          expect(response.parsed_body['email_sent']).to eq(false)
          expect(LogShare.order(:id).last!.email).to eq(params[:log_share][:email].downcase)
        end
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: log_share.id }) }

    let(:log_share) { log_shares(:log_share) }

    context 'when attempting to destroy the log_share of another user' do
      let(:owning_user) { log_share.log.user }
      let(:user) { User.where.not(id: owning_user).first! }

      it 'does not destroy the log_share' do
        expect { delete_destroy }.not_to change { log_share.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response).to have_http_status(404)
      end
    end

    context "when attempting to destroy one's own log_share" do
      let(:user) { log_share.log.user }

      it 'destroys the log_share' do
        expect { delete_destroy }.to change {
          LogShare.find_by(id: log_share.id)
        }.from(LogShare).to(nil)
      end

      it 'returns a 204 status code' do
        delete_destroy
        expect(response).to have_http_status(204)
      end
    end
  end
end
