# frozen_string_literal: true

RSpec.describe SmsRecords::SaveSmsRecord do
  subject(:save_sms_record_action) { SmsRecords::SaveSmsRecord.new(save_sms_record_params) }

  let(:save_sms_record_params) do
    {
      nexmo_response_data: nexmo_response_data,
      user: user,
    }
  end
  let(:nexmo_response_data) { VendorTestApi::Nexmo.single_message_response }
  let(:user) { users(:user) }

  describe '#execute' do
    subject(:execute) { save_sms_record_action.execute }

    context 'when a single SMS message was sent' do
      it 'creates one SmsRecord belonging to the user' do
        expect{
          execute
        }.to change{
          user.sms_records.count
        }.by(1)
      end

      describe 'the created SmsRecord' do
        subject(:sms_record) do
          user.sms_records.destroy_all
          execute
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

      context "when the provided nexmo_response_data hash doesn't include a message-id" do
        before { nexmo_response_data.dig('messages', 0).delete('message-id') }

        it 'raises an error' do
          expect { execute }.to raise_error(ActiveActions::TypeMismatch)
        end
      end

      context "when the provided nexmo_response_data hash doesn't include an error-text" do
        before { nexmo_response_data.dig('messages', 0).delete('error-text') }

        it 'does not raise any error' do
          expect { execute }.not_to raise_error
        end
      end
    end
  end
end
