# frozen_string_literal: true

RSpec.describe SaveRequest do
  subject(:worker) { SaveRequest.new }

  describe '#perform' do
    subject(:perform) { worker.perform(request_id) }

    let(:request_id) { SecureRandom.uuid }
    let(:stubbed_data_manager) { instance_double(SaveRequest::StashedDataManager) }
    let(:stubbed_initial_stashed_json) { { some: :data } }
    let(:stubbed_final_stashed_json) { { more: :data } }
    let(:stubbed_additional_data) { { 'params' => {} } }

    before do
      expect(SaveRequest::StashedDataManager).to receive(:new).and_return(stubbed_data_manager)
      allow(stubbed_data_manager).
        to receive(:initial_stashed_json).
        at_least(:once).
        and_return(stubbed_initial_stashed_json)
      allow(stubbed_data_manager).
        to receive(:final_stashed_json).
        at_least(:once).
        and_return(stubbed_final_stashed_json)
      allow(stubbed_data_manager).
        to receive(:stashed_data).
        at_least(:once).
        and_return(
          stubbed_initial_stashed_json.
            merge(stubbed_final_stashed_json).
            merge(stubbed_additional_data),
        )
      allow(stubbed_data_manager).to receive(:delete_request_data)
    end

    context 'when the stashed data is all missing' do
      let(:stubbed_initial_stashed_json) { {} }
      let(:stubbed_final_stashed_json) { {} }

      before do
        expect(stubbed_initial_stashed_json).to be_blank
        expect(stubbed_final_stashed_json).to be_blank
      end

      it 'sends some messages to the ErrorLogger' do
        expect(ErrorLogger).to receive(:warn).at_least(1)

        perform
      end
    end

    context 'when the stashed JSON data is not blank' do
      let(:stubbed_initial_stashed_json) { { some: :data } }
      let(:stubbed_final_stashed_json) { { more: :data } }
      let(:stubbed_additional_data) do
        {
          'params' => {},
          'requested_at_as_float' => 3453.01,
        }
      end

      context 'when the request_id is an empty string' do
        let(:request_id) { '' }

        it 'calls #handle_error_saving_request and raises an error' do
          expect(worker).to receive(:handle_error_saving_request).and_call_original
          expect(worker.logger).to receive(:warn) # suppress output from actually being printed
          expect { perform }.to raise_error(Request::CreateRequestError, 'Failed to save a Request')
        end
      end

      context 'when the stashed JSON has enough data to save a Request' do
        let(:stubbed_additional_data) do
          super().merge(
            'url' => '/',
            'handler' => 'home#index',
            'method' => 'GET',
            'ip' => '123.321.456.654',
            'status' => 200,
          )
        end

        context 'when the request has already been saved' do
          before { Request.first!.update!(request_id:) }

          it 'does not raise an error' do
            expect { perform }.not_to raise_error
          end
        end

        context 'when the request was an UptimeRobot ping' do
          let(:stubbed_additional_data) { super().merge('params' => { 'uptime_robot' => '1' }) }

          it 'does not create a request' do
            expect { perform }.not_to change { Request.count }
          end

          it 'deletes the stashed data' do
            perform
            expect(stubbed_data_manager).to have_received(:delete_request_data)
          end
        end

        context 'when the request was for a blog asset' do
          let(:stubbed_additional_data) do
            super().merge('handler' => 'blog#assets')
          end

          it 'does not create a request' do
            expect { perform }.not_to change { Request.count }
          end

          it 'deletes the stashed data' do
            perform
            expect(stubbed_data_manager).to have_received(:delete_request_data)
          end
        end

        context 'when there is an auth_token_id in the initial stashed JSON' do
          let(:stubbed_initial_stashed_json) { super().merge('auth_token_id' => auth_token.id) }
          let(:auth_token) { AuthToken.first! }

          it 'creates a Request associated with that auth_token' do
            request_ids_before = Request.ids

            expect { perform }.to change { Request.count }.by(1)

            request = Request.where.not(id: request_ids_before).first!
            expect(request.auth_token).to eq(auth_token)
          end
        end
      end
    end

    context 'when the request merits a ban' do
      let(:stubbed_additional_data) do
        {
          'url' => '/404',
          'params' => params,
          'ip' => request_ip,
        }
      end
      let(:params) { { "HHHHF\u0000\u0000\u0000K\u0000\u0000\u0000\u0000\u0018 " => nil } }
      let(:request_ip) { Faker::Internet.ip_v4_address }

      context 'when Sidekiq executes jobs', :inline_sidekiq do
        it 'creates an IpBlock' do
          expect { perform }.to change { IpBlock.count }.by(1)
          ip_block = IpBlock.last!
          expect(ip_block.ip).to eq(request_ip)
          expect(ip_block.reason).to eq(JSON(params.keys + params.values))
        end
      end
    end
  end
end
