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
