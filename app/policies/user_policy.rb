class UserPolicy < ApplicationPolicy
  def show?
    own_record?
  end

  private

  def own_record?
    @user == @record
  end
end
