# frozen_string_literal: true

RSpec.describe Api::TextMessagesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    before { NexmoTestApi.stub_post_success }

    let(:params) do
      {
        text_message: {
          message_type: 'grocery_store_items_needed',
          message_params: {
            store_id: user.stores.first.id,
          },
        },
      }
    end

    describe 'authorization' do
      describe 'when the user may send SMS messages' do
        verify { expect(user.may_send_sms?).to eq(true) }

        context 'when NEXMO_API_KEY is set in ENV' do
          before do
            expect(ENV).to receive(:[]).with('NEXMO_API_KEY').and_return('DEFabc123')
            allow(ENV).to receive(:[]).and_call_original # pass other calls through
          end

          it 'attempts to send a text message' do
            expect(NexmoClient).to receive(:send_text!).and_call_original
            post(:create, params: params)
          end
        end
      end

      describe 'when the user may not send SMS messages' do
        before { user.update!(sms_allowance: 0) }

        verify { expect(user.may_send_sms?).to eq(false) }

        it 'does not attempt to send a text message' do
          expect(NexmoClient).not_to receive(:send_text!)
          post(:create, params: params)
        end

        it 'returns a 403 status code' do
          post(:create, params: params)
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
