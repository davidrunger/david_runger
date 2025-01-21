RSpec.describe LogsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#index' do
    subject(:get_index) { get(:index, params:) }

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

          expect(response).to have_http_status(200)
          expect(response.body).to include(other_user_log.name)
        end

        describe 'bootstrap data' do
          subject(:bootstrap_data) do
            get_index
            assigns[:bootstrap_data].as_json
          end

          it 'has only one log' do
            expect(bootstrap_data['logs'].size).to eq(1)
          end

          describe 'the log' do
            subject(:log_data_keys) { bootstrap_data.dig('logs', 0).keys.map(&:to_s) }

            it 'does not reveal confidential log information' do
              expect(log_data_keys).not_to include('log_shares')
              expect(log_data_keys).not_to include('publicly_viewable')
              expect(log_data_keys).not_to include('reminder_time_in_seconds')
              expect(log_data_keys).to match_array(%w[
                data_label
                data_type
                description
                id
                name
                slug
                user
              ])
            end
          end
        end
      end
    end

    context 'when there is no user_id param (i.e. user viewing their own log)' do
      let(:params) { { slug: log.slug } }

      let(:log) { user.logs.number.first! }

      it 'responds with 200 and bootstraps info about the log' do
        get_index

        expect(response).to have_http_status(200)
        expect(response.body).to include(log.name)
      end

      context 'when there is a blank string `new_entry` param' do
        let(:params) { super().merge(new_entry: '') }

        context "when there is an auth_token param that is one of the user's auth_token secrets" do
          let(:params) { super().merge(auth_token: user.auth_tokens.first!.secret) }

          it 'does not create a log_entry' do
            expect { get_index }.not_to change { log.reload.log_entries.size }
          end

          it 'renders the logs#index page' do
            expect(get_index).to render_template('logs/index')
          end
        end
      end
    end
  end
end
