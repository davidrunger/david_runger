# frozen_string_literal: true

RSpec.describe SmsRecord do
  subject(:sms_record) { sms_records(:sms_record) }

  it { is_expected.to belong_to(:user) }

  describe '::create_records_from_httparty_response' do
    subject(:create_records_from_httparty_response) do
      SmsRecord.create_records_from_httparty_response(response: response, user: user)
    end

    let(:user) { users(:user) }
    let(:response) { instance_double('HTTParty::Response') }

    context 'when a single SMS message was sent' do
      before do
        expect(response).
          to receive(:parsed_response).
          and_return(NexmoTestApi.single_message_response)
      end

      it 'creates one SmsRecord belonging to the user' do
        expect{
          create_records_from_httparty_response
        }.to change{
          user.sms_records.count
        }.by(1)
      end

      describe 'the created SmsRecord' do
        subject(:sms_record) do
          user.sms_records.destroy_all
          create_records_from_httparty_response
          user.sms_records.last
        end

        it 'has a cost' do
          expect(sms_record.cost).to be_present
        end

        it 'doesnt have an error' do
          expect(sms_record.error).to be_blank
        end

        it 'has a nexmo_id' do
          expect(sms_record.nexmo_id).to be_present
        end

        it 'has a status' do
          expect(sms_record.status).to be_present
        end

        it 'has a to' do
          expect(sms_record.to).to be_present
        end
      end
    end
  end

  describe '#nexmo_message_hash_to_attributes' do
    subject(:nexmo_message_hash_to_attributes) do
      SmsRecord.__send__(:nexmo_message_hash_to_attributes, message_hash)
    end

    context 'when there is no error' do
      let(:message_hash) { NexmoTestApi.single_message_response['messages'].first }

      it 'maps the Nexmo json to attributes of the SmsRecord model' do
        expect(nexmo_message_hash_to_attributes).to eq(
          cost: Float(message_hash['message-price']),
          error: nil,
          nexmo_id: message_hash['message-id'],
          status: message_hash['status'],
          to: message_hash['to'],
        )
      end
    end
  end
end
