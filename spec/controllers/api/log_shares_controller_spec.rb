# frozen_string_literal: true

RSpec.describe Api::LogSharesController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:log) { user.logs.joins(:log_shares).first! }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the log share params are invalid' do
      let(:invalid_params) { { log_share: { email: nil, log_id: log.id } } }
      let(:params) { invalid_params }

      it 'returns a 422 status code' do
        post_create
        expect(response.status).to eq(422)
      end
    end

    context 'when the log share params are valid' do
      let(:valid_params) { { log_share: { email: Faker::Internet.email, log_id: log.id } } }
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      it 'creates a log share' do
        expect { post_create }.to change { LogShare.count }.by(1)
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
        expect(response.status).to eq(404)
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
        expect(response.status).to eq(204)
      end
    end
  end
end
