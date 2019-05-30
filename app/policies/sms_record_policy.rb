# frozen_string_literal: true

class SmsRecordPolicy < ApplicationPolicy
  def create?
    @user.may_send_sms?
  end
end
