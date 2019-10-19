# frozen_string_literal: true

RSpec.describe Api::LogEntriesController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:log) { user.logs.first! }

  describe '#create' do
    context 'when the log entry params are invalid' do
      let(:invalid_params) { {log_entry: {data: nil, log_id: log.id}} }

      it 'returns a 422 status code' do
        post(:create, params: invalid_params)
        expect(response.status).to eq(422)
      end
    end

    context 'when the log entry params are valid' do
      let(:log) { user.logs.where(data_type: 'number').first! }
      let(:valid_params) { {log_entry: {data: 122, log_id: log.id}} }

      it 'returns a 201 status code' do
        post(:create, params: valid_params)
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
end
