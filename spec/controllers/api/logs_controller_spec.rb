RSpec.describe Api::LogsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    context 'when the log being created is valid' do
      let(:valid_params) do
        {
          log: {
            name: 'Resting Heart Rate',
            data_label: 'Heart Rate',
            data_type: 'number',
          },
        }
      end
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response).to have_http_status(201)
      end

      it 'responds with the log as JSON' do
        post_create
        expect(response.parsed_body).to include(
          'data_label' => 'Heart Rate',
          'data_type' => 'number',
          'description' => nil,
          'id' => Integer,
          'name' => 'Resting Heart Rate',
          'publicly_viewable' => false,
          'reminder_time_in_seconds' => nil,
          'slug' => 'resting-heart-rate',
        )
      end
    end

    context 'when the log being created is invalid' do
      let(:invalid_params) { { log: { name: '' } } }
      let(:params) { invalid_params }

      it 'logs info about the log and why it is invalid' do
        allow(Rails.logger).to receive(:info).and_call_original

        post_create

        checked_log_line_expectations = false
        expect(Rails.logger).to have_received(:info) do |logged_string|
          # ignore an expected log line that we aren't interested in
          break if logged_string.include?('path=/api/logs method=POST')

          # make sure that we get here at some point
          checked_log_line_expectations = true
          expect(logged_string).to match(/Failed to create log\./)
          expect(logged_string).to match(/errors={.*name: \["can't be blank"\].*}/)
          expect(logged_string).to match(/attributes={.*"name" => nil\b.*}/)
        end
        expect(checked_log_line_expectations).to eq(true)
      end

      it 'returns a 422 status code' do
        post_create
        expect(response).to have_http_status(422)
      end
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params:) }

    context 'when a log has `publicly_viewable: false`' do
      before { expect(log.publicly_viewable?).to eq(false) }

      let(:log) { logs(:number_log) }

      context 'when the params have `publicly_viewable: true`' do
        let(:params) { { id: log.id, log: { publicly_viewable: true } } }

        it 'changes the log to `publicly_viewable: true`' do
          expect { patch_update }.to change { log.reload.publicly_viewable }.from(false).to(true)
        end

        it 'responds with the log as JSON' do
          patch_update
          expect(response.parsed_body).to include(
            'data_label' => log.data_label,
            'data_type' => 'number',
            'description' => log.description,
            'id' => Integer,
            'name' => log.name,
            'publicly_viewable' => log.reload.publicly_viewable,
            'reminder_time_in_seconds' => Integer,
            'slug' => log.slug,
          )
        end
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: log.id }) }

    let(:log) { logs(:number_log) }

    context 'when attempting to destroy the log of another user' do
      let(:owning_user) { log.user }
      let(:user) { User.where.not(id: owning_user).first! }

      it 'does not destroy the log' do
        expect { delete_destroy }.not_to change { log.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response).to have_http_status(404)
      end
    end

    context "when attempting to destroy one's own log" do
      let(:user) { log.user }

      context 'when the log has more than one entry' do
        before { expect(log.log_entries.size).to be > 1 }

        it 'destroys the log and returns a 204 status code without raising an N+1 query error' do
          expect { delete_destroy }.to change { Log.find_by(id: log.id) }.from(Log).to(nil)

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
