class UserPolicy < ApplicationPolicy
  def create?
    true
  end

  def show?
    own_record?
  end

  private

  def own_record?
    @user == @record
  end
end
