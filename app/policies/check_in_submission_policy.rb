class CheckInSubmissionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.check_in_submissions
    end
  end
end
