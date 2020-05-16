# frozen_string_literal: true

RSpec.describe SmsRecordPolicy do
  let(:user) { users(:user) }

  permissions :create? do
    context 'when User#may_send_sms? is true' do
      before { expect(user.may_send_sms?).to be(true) }

      it 'permits sending a text message' do
        expect(SmsRecordPolicy).to permit(user)
      end
    end

    context 'when User#may_send_sms? is false' do
      before do
        user.update!(sms_allowance: 0)
        expect(user.may_send_sms?).to be(false)
      end

      it 'does not permit sending a text message' do
        expect(SmsRecordPolicy).not_to permit(user)
      end
    end
  end
end
