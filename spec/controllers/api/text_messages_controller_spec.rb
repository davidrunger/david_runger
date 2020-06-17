# frozen_string_literal: true

RSpec.describe Api::TextMessagesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    let(:valid_params) do
      {
        text_message: {
          message_type: 'grocery_store_items_needed',
          message_params: {
            store_id: user.stores.first.id,
          },
        },
      }
    end
    let(:invalid_params) do
      {
        text_message: {
          message_type: 'an_unknown_message_type',
          message_params: {
            store_id: user.stores.first.id,
          },
        },
      }
    end

    context 'when the user may send SMS messages' do
      verify { expect(user.may_send_sms?).to eq(true) }

      context 'when the user does not have a phone number' do
        before { user.update!(phone: nil) }

        let(:params) { valid_params }

        it 'does not attempt to send a text message and raises an error' do
          expect(NexmoClient).not_to receive(:send_text!)
          post_create
        end

        it 'responds with JSON info about the validation error(s)' do
          post_create
          expect(response.parsed_body).to eq('error' => "Phone can't be blank")
        end
      end

      context 'when the message params are invalid' do
        let(:params) { invalid_params }

        it 'does not attempt to send a text message and raises an error' do
          expect(NexmoClient).not_to receive(:send_text!)
          expect { post_create }.to raise_error(SmsRecords::GenerateMessage::InvalidMessageType)
        end
      end

      context 'when the message params are valid' do
        let(:params) { valid_params }

        context 'when NEXMO_API_KEY is set in ENV' do
          before do
            expect(ENV).to receive(:[]).with('NEXMO_API_KEY').and_return('DEFabc123')
            allow(ENV).to receive(:[]).and_call_original # pass other calls through
          end

          it 'attempts to send a text message' do
            VendorTestApi::Nexmo.stub_post_success
            expect(NexmoClient).to receive(:send_text!).and_call_original
            post_create
          end

          context 'when sending the message succeeds' do
            before { VendorTestApi::Nexmo.stub_post_success }

            it 'responds with 201 status' do
              post_create
              expect(response.status).to eq(201)
            end
          end

          context 'when sending the message fails' do
            before { VendorTestApi::Nexmo.stub_post_failure }

            it 'responds with 400 status' do
              post_create
              expect(response.status).to eq(400)
            end

            it 'responds with error JSON' do
              post_create
              expect(response.parsed_body).to include(
                'error' => 'An error occurred when sending the text message',
              )
            end
          end
        end
      end
    end

    context 'when the user may not send SMS messages' do
      before { user.update!(sms_allowance: 0) }

      verify { expect(user.may_send_sms?).to eq(false) }

      context 'when the message params are valid' do
        let(:params) { valid_params }

        it 'does not attempt to send a text message' do
          expect(NexmoClient).not_to receive(:send_text!)
          post_create
        end

        it 'returns a 403 status code' do
          post_create
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
