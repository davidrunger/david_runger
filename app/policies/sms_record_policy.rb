# frozen_string_literal: true

class SmsRecordPolicy < ApplicationPolicy
  def create?
    @user.sms_usage < @user.sms_allowance
  end
end
