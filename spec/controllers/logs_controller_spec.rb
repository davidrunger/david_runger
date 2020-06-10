# frozen_string_literal: true

RSpec.describe LogsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#index' do
    subject(:get_index) { get(:index, params: params) }

    context 'when there is a user_id param (for a shared log)' do
      let(:params) { { user_id: other_user.id, slug: other_user_log.slug } }
      let(:other_user) { User.where.not(id: user).joins(:logs).first! }
      let(:other_user_log) { other_user.logs.first! }

      context 'when the log is not publicly viewable' do
        before { expect(other_user_log).not_to be_publicly_viewable }

        it 'redirects with a flash message' do
          get_index

          expect(response.status).to redirect_to(root_path)
          expect(flash[:alert]).to eq('You are not authorized to perform this action.')
        end
      end

      context 'when the log is publicly viewable' do
        before { other_user_log.update!(publicly_viewable: true) }

        it 'responds with 200 and bootstraps info about the log' do
          get_index

          expect(response.status).to eq(200)
          expect(response.body).to include(other_user_log.name)
        end
      end
    end

    context 'when there is no user_id param (i.e. user viewing their own log)' do
      let(:params) { { slug: log.slug } }

      let(:log) { user.logs.number.first! }

      it 'responds with 200 and bootstraps info about the log' do
        get_index

        expect(response.status).to eq(200)
        expect(response.body).to include(log.name)
      end

      context 'when there is a `new_entry` query param' do
        let(:params) { super().merge(new_entry: '199.8') }

        context "when there is an `auth_token` param that is the user's `auth_token`" do
          let(:params) { super().merge(auth_token: user.auth_token) }

          it 'creates a log entry with the value of the `new_entry` query param' do
            expect { get_index }.to change { log.log_entries.size }.by(1)
            log_entry = log.log_entries.order(:created_at).last!
            expect(log_entry.data).to eq(Float(params[:new_entry]))
          end
        end

        context "when there is an `auth_token` param but it is not the user's `auth_token`" do
          let(:params) { super().merge(auth_token: SecureRandom.uuid) }

          it 'raises an error and does not create a log entry' do
            expect { get_index }.not_to change { log.reload.log_entries.size }
          end
        end

        context 'when there is no `auth_token` param' do
          let(:params) { super().merge(auth_token: '') }

          it 'raises an error and does not create a log entry' do
            expect { get_index }.not_to change { log.reload.log_entries.size }
          end
        end
      end
    end
  end
end
