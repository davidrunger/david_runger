class ItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Item.where(user: [@user, @user.spouse].compact)
    end
  end

  def update?
    (item.user == @user) || !!(@user.spouse && (item.user == @user.spouse))
  end

  def destroy?
    own_record?
  end

  def manage_availabilities?
    own_record?
  end

  def merge?
    own_record?
  end

  private

  def item
    @record
  end
end
