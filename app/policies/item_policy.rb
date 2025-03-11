class ItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Item.
        where(id: @user.items).
        or(Item.where(id: @user.spouse&.items))
    end
  end

  def update?
    (item.user == @user) || !!(@user.spouse && (item.user == @user.spouse))
  end

  def destroy?
    own_record?
  end

  private

  def item
    @record
  end
end
