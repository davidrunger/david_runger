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
    [@user.id, @user.spouse.id].sort == @record.partners.ids.sort
  end
end
