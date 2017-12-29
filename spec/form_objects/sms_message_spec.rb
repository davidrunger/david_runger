require 'spec_helper'

RSpec.describe SmsMessage do
  subject(:sms_message) { SmsMessage.new(sms_message_params) }
  let(:sms_message_params) do
    {
      user: user,
      message_type: message_type,
      message_params: message_params,
    }
  end
  let(:user) { users(:user) }
  let(:message_type) { 'grocery_store_items_needed' }
  let(:message_params) { {store_id: user.stores.first!.id} }

  describe 'validations' do
    subject(:error_messages) do
      sms_message.valid?
      sms_message.errors.full_messages
    end

    describe 'validating that the user has a phone number' do
      let(:missing_phone_error) { "User phone can't be blank" }

      context 'when the user has a phone number' do
        before { expect(user.phone).to be_present }

        it 'should not have a validation error about a missing phone number' do
          expect(error_messages).not_to include(missing_phone_error)
        end
      end

      context 'when the user does not have a phone number' do
        before do
          user.update!(phone: nil)
          expect(user.phone).to be_blank
        end

        it 'should have a validation error about a missing phone number' do
          expect(error_messages).to include(missing_phone_error)
        end
      end
    end
  end
end
