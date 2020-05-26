# frozen_string_literal: true

RSpec.describe Api::LogEntriesController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:log) { user.logs.first! }
  let(:iso8601_z_regex) { /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/ }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the log entry params are invalid' do
      let(:invalid_params) { { log_entry: { data: nil, log_id: log.id } } }
      let(:params) { invalid_params }

      it 'returns a 422 status code' do
        post_create
        expect(response.status).to eq(422)
      end
    end

    context 'when the log entry params are valid' do
      let(:log) { user.logs.where(data_type: 'number').first! }
      let(:valid_params) { { log_entry: { data: 122, log_id: log.id } } }
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      it 'returns the serialized newly created log entry with a created_at ISO-8601 Z timestamp' do
        post_create

        expect(response.parsed_body['created_at']).to match(iso8601_z_regex)
      end

      context 'when there is a note in the log entry params' do
        let(:params_with_note) do
          valid_params.deep_merge(log_entry: { note: 'Had a lot of salt yesterday' })
        end

        it 'creates a log entry with a note' do
          expect{
            post(:create, params: params_with_note)
          }.to change{
            log.log_entries.where.not(note: nil).size
          }.by(1)
        end
      end
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    let(:log_entry) { logs(:text_log).log_entries.first! }
    let(:base_params) { { id: log_entry.id } }

    context 'when attempting to update the log entry of another user' do
      let(:owning_user) { log_entry.log.user }
      let(:user) { User.where.not(id: owning_user).first! }
      let(:params) { base_params.merge(log_entry: { data: log_entry.data + ' ...changed.' }) }

      it 'does not update the log_entry' do
        expect { patch_update }.not_to change { log_entry.reload.attributes }
      end

      it 'returns a 404 status code' do
        patch_update
        expect(response.status).to eq(404)
      end
    end

    context 'when the log entry is being updated with invalid params' do
      let(:invalid_params) { { log_entry: { data: '' } } }
      let(:params) { base_params.merge(invalid_params) }

      it 'does not update the log_entry' do
        expect { patch_update }.not_to change { log_entry.reload.attributes }
      end

      it 'returns a 422 status code' do
        patch_update
        expect(response.status).to eq(422)
      end
    end

    context 'when the log entry is being updated with valid params' do
      let(:valid_params) { { log_entry: { data: log_entry.data + ' ...changed.' } } }
      let(:params) { base_params.merge(valid_params) }

      it 'updates the log_entry' do
        expect { patch_update }.to change { log_entry.reload.data }
      end

      it 'returns the serialized, updated log entry with a created_at ISO-8601 Z timestamp' do
        patch_update

        expect(response.parsed_body['created_at']).to match(iso8601_z_regex)
      end

      it 'returns a 200 status code' do
        patch_update
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) do
      delete(
        :destroy,
        params: {
          id: log_entry.id,
          log_id: log_entry.log_id,
        },
      )
    end

    let(:log_entry) { logs(:number_log).log_entries.first! }

    context 'when attempting to destroy the log_entry of another user' do
      let(:owning_user) { log_entry.log.user }
      let(:user) { User.where.not(id: owning_user).first! }

      it 'does not destroy the log_entry' do
        expect { delete_destroy }.not_to change { log_entry.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response.status).to eq(404)
      end
    end

    context "when attempting to destroy one's own log_entry" do
      let(:user) { log_entry.log.user }

      it 'destroys the log_entry' do
        expect { delete_destroy }.to change {
          LogEntries::NumberLogEntry.find_by(id: log_entry.id)
        }.from(LogEntries::NumberLogEntry).to(nil)
      end

      it 'returns a 204 status code' do
        delete_destroy
        expect(response.status).to eq(204)
      end
    end
  end

  describe '#index' do
    subject(:get_index) { get(:index, params: params) }

    context 'when a log_id param is provided' do
      let(:params) { { log_id: log.id } }

      it 'returns data only about that particular log' do
        get_index

        returned_log_entry_ids = response.parsed_body.map { |log_entry| log_entry['id'] }
        log_entry_ids = log.log_entries.pluck(:id)
        expect(returned_log_entry_ids).to match_array(log_entry_ids)
      end

      it 'formats the created_at timestamps as an ISO-8601 time with "Z" timezone' do
        get_index

        expect(response.parsed_body.map { _1['created_at'] }).to all(match(iso8601_z_regex))
      end
    end

    context 'when a log_id param is not provided' do
      let(:params) { {} }

      it 'returns all log entries of the current_user' do
        get_index

        simplified_response_data =
          response.parsed_body.map do |log_entry|
            log_entry.slice('id')
          end
        expected_simplified_response_data =
          user.logs.map(&:log_entries).flatten.map { |log_entry| { 'id' => log_entry.id } }

        expect(simplified_response_data).to match_array(expected_simplified_response_data)
      end
    end
  end
end
