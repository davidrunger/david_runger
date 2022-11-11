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

  def show_groceries?
    [@user.id, @user.spouse.id].sort == [@record.partner_1_id, @record.partner_2_id].sort
  end
end
