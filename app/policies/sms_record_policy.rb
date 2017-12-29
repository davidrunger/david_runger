class SmsRecordPolicy < ApplicationPolicy
  def create?
    @user.may_send_sms?
  end
end
