RSpec.describe LogEntriesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:params) { { slug: log.slug } }
    let(:log) { user.logs.number.first! }

    context 'when there is a non-blank `new_entry` query param' do
      let(:params) { super().merge(new_entry: '199.8') }

      context 'when the user has an auth_token whose secret is the submitted auth token param' do
        let(:params) { super().merge(auth_token: user.auth_tokens.first!.secret) }

        it 'creates a log entry with the value of the `new_entry` query param' do
          expect { post_create }.to change { log.log_entries.size }.by(1)
          log_entry = log.log_entries.order(:created_at).last!
          expect(log_entry.data).to eq(Float(params[:new_entry]))
        end

        context 'when the log is a number log' do
          before { expect(log.data_type).to eq('number') }

          context 'when the `new_entry` param has a space' do
            before { expect(params[:new_entry]).to include(' ') }

            let(:new_entry_data) { 280.4 }
            let(:new_entry_note) { 'yikes! 😬 not good!' }
            let(:params) { super().merge(new_entry: "#{new_entry_data} #{new_entry_note}") }

            it 'creates a new log entry by splitting the `new_entry` param into data and note' do
              expect { post_create }.to change { log.log_entries.size }.by(1)
              log_entry = log.log_entries.order(:created_at).last!

              expect(log_entry.data).to eq(new_entry_data)
              expect(log_entry.note).to eq(new_entry_note)
            end
          end
        end
      end

      context "when there is an `auth_token` param but it is not the user's `auth_token`" do
        let(:params) { super().merge(auth_token: SecureRandom.uuid) }

        it 'raises an error and does not create a log entry' do
          expect { post_create }.not_to change { log.reload.log_entries.size }
        end
      end

      context 'when there is no `auth_token` param' do
        let(:params) { super().merge(auth_token: '') }

        it 'does not create a log entry' do
          expect { post_create }.not_to change { log.reload.log_entries.size }
        end
      end
    end

    context 'when there is a blank string `new_entry` param' do
      let(:params) { super().merge(new_entry: '') }

      context "when there is an auth_token param that is one of the user's auth_token secrets" do
        let(:params) { super().merge(auth_token: user.auth_tokens.first!.secret) }

        it 'does not create a log_entry' do
          expect { post_create }.not_to change { log.reload.log_entries.size }
        end

        it 'redirects to the logs index page' do
          expect(post_create).to redirect_to(logs_path)
        end
      end
    end
  end
end
