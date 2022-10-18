# frozen_string_literal: true

class ItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Item.
        where(id: @user.items).
        or(Item.where(id: @user.spouse&.items))
    end
  end

  def update?
    scope.exists?(id: item.id)
  end

  def destroy?
    own_record?
  end

  private

  def item
    @record
  end
end
