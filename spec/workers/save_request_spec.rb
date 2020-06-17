# frozen_string_literal: true

RSpec.describe SaveRequest do
  subject(:worker) { SaveRequest.new }

  describe '#perform' do
    subject(:perform) { worker.perform(request_id) }

    let(:request_id) { SecureRandom.uuid }
    let(:stubbed_data_manager) { instance_double(SaveRequest::StashedDataManager) }

    before do
      expect(SaveRequest::StashedDataManager).to receive(:new).and_return(stubbed_data_manager)
    end

    context 'when the stashed data is all missing' do
      before do
        expect(stubbed_data_manager).to receive(:initial_stashed_json).at_least(1).and_return(nil)
        expect(stubbed_data_manager).to receive(:final_stashed_json).at_least(1).and_return(nil)
        expect(stubbed_data_manager).to receive(:stashed_data).and_return({ 'params' => {} })
        expect(stubbed_data_manager).to receive(:delete_request_data)
      end

      it 'sends some messages to the ErrorLogger' do
        expect(ErrorLogger).to receive(:warn).at_least(1)

        perform
      end
    end

    context 'when the request_id is an empty string' do
      let(:request_id) { '' }

      before do
        expect(stubbed_data_manager).
          to receive(:initial_stashed_json).
          at_least(:once).
          and_return(some: :data)
        expect(stubbed_data_manager).
          to receive(:final_stashed_json).
          at_least(:once).
          and_return(more: :data)
        expect(stubbed_data_manager).to receive(:stashed_data).at_least(:once).and_return(
          'params' => {},
          'requested_at_as_float' => 3453.01,
        )
      end

      it 'calls #handle_error_saving_request and raises an error' do
        expect(worker).to receive(:handle_error_saving_request).and_call_original
        expect(worker.logger).to receive(:warn) # suppress output from actually being printed
        expect { perform }.to raise_error(Request::CreateRequestError, 'Failed to save a Request')
      end
    end
  end
end
