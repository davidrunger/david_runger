# frozen_string_literal: true

RSpec.describe SmsRecords::PostToNexmo do
  subject(:post_to_nexmo_action) { SmsRecords::PostToNexmo.new(post_to_nexmo_params) }

  let(:post_to_nexmo_params) do
    {
      message_body: message_body,
      phone_number: '15551239876',
    }
  end
  let(:message_body) { 'Hi there!' }

  describe 'initializing the action' do
    context 'when the message_body is a blank string' do
      let(:post_to_nexmo_params) { super().merge(message_body: '') }

      it 'raises an error' do
        expect { post_to_nexmo_action }.to raise_error(
          ActiveActions::TypeMismatch,
          <<~ERROR.squish)
            One or more required params are of the wrong type: `message_body` is expected to be
            shaped like String validating {:presence=>true}, but was `""`.
          ERROR
      end
    end

    context 'when the phone_number is a blank string' do
      let(:post_to_nexmo_params) { super().merge(phone_number: '') }

      it 'raises an error' do
        expect { post_to_nexmo_action }.to raise_error(
          ActiveActions::TypeMismatch,
          <<~ERROR.squish)
            One or more required params are of the wrong type: `phone_number` is expected to be
            shaped like String validating {:presence=>true}, but was `""`.
          ERROR
      end
    end
  end

  describe '#execute' do
    subject(:execute) { post_to_nexmo_action.execute }

    context 'when NEXMO_API_KEY is not present in the ENV' do
      before do
        expect(ENV.fetch('NEXMO_API_KEY', nil)).not_to be_present
        # suppress `puts` from actually printing
        expect(post_to_nexmo_action).to receive(:puts)
      end

      it 'does not actually post to Nexmo' do
        expect(post_to_nexmo_action).not_to receive(:send_via_nexmo!)
        expect(NexmoClient).not_to receive(:send_text!)
        execute
      end

      it 'calls #log_message' do
        expect(post_to_nexmo_action).to receive(:log_message).and_call_original
        execute
      end
    end
  end

  describe '#log_message' do
    subject(:log_message) { post_to_nexmo_action.send(:log_message) }

    it 'prints the message to STDOUT' do
      expect(post_to_nexmo_action).to receive(:puts).with(<<~EXPECTED_LOG)
        NEXMO_API_KEY is blank; message would have been:
        ~~~~~~~~~~~~~~~~~~~~~
        #{message_body}
        =====================
      EXPECTED_LOG

      log_message
    end
  end
end
