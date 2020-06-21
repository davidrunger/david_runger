# frozen_string_literal: true

RSpec.describe SmsRecords::SaveSmsRecord do
  subject(:save_sms_record_action) { SmsRecords::SaveSmsRecord.new(save_sms_record_params) }

  let(:save_sms_record_params) do
    {
      nexmo_response_data: VendorTestApi::Nexmo.single_message_response,
      user: user,
    }
  end
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
    end
  end
end
