# frozen_string_literal: true

RSpec.describe SmsRecordPolicy do
  let(:user) { users(:user) }

  permissions :create? do
    context 'when the user has used less than their SMS allowance' do
      before { expect(user.sms_usage).to be < user.sms_allowance }

      it 'permits sending a text message' do
        expect(SmsRecordPolicy).to permit(user)
      end
    end

    context 'when the user has used more than their SMS allowance' do
      before do
        user.update!(sms_allowance: 0)
        expect(user.sms_usage).to be > user.sms_allowance
      end

      it 'does not permit sending a text message' do
        expect(SmsRecordPolicy).not_to permit(user)
      end
    end
  end
end
