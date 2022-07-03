# frozen_string_literal: true

class MarriagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Marriage.where(id: @user.marriage)
    end
  end

  def propose?
    true
  end
end
