# frozen_string_literal: true

class CheckInPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.marriage.check_ins
    end
  end
end
