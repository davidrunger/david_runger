# frozen_string_literal: true

RSpec.describe Api::LogEntriesController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:log) { user.logs.first! }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the log entry params are invalid' do
      let(:invalid_params) { {log_entry: {data: nil, log_id: log.id}} }
      let(:params) { invalid_params }

      it 'returns a 422 status code' do
        post_create
        expect(response.status).to eq(422)
      end
    end

    context 'when the log entry params are valid' do
      let(:log) { user.logs.where(data_type: 'number').first! }
      let(:valid_params) { {log_entry: {data: 122, log_id: log.id}} }
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      context 'when there is a note in the log entry params' do
        let(:params_with_note) do
          valid_params.deep_merge(log_entry: {note: 'Had a lot of salt yesterday'})
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
    let(:base_params) { {id: log_entry.id} }

    context 'when attempting to update the log entry of another user' do
      let(:owning_user) { log_entry.log.user }
      let(:user) { User.where.not(id: owning_user).first! }
      let(:params) { base_params.merge(log_entry: {data: log_entry.data + ' ...changed.'}) }

      it 'does not update the log_entry' do
        expect { patch_update }.not_to change { log_entry.reload.attributes }
      end

      it 'returns a 404 status code' do
        patch_update
        expect(response.status).to eq(404)
      end
    end

    context 'when the log entry is being updated with invalid params' do
      let(:invalid_params) { {log_entry: {data: ''}} }
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
      let(:valid_params) { {log_entry: {data: log_entry.data + ' ...changed.'}} }
      let(:params) { base_params.merge(valid_params) }

      it 'updates the log_entry' do
        expect { patch_update }.to change { log_entry.reload.data }
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
end
