# frozen_string_literal: true

class CheckInPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.marriage.check_ins
    end
  end

  private

  def own_record?
    @user.in?(check_in.marriage.partners)
  end

  def check_in
    @record
  end
end
