class ReificationPolicy < ApplicationPolicy
  def create?
    own_record?
  end

  private

  def own_record?
    @record.reify.user == @user
  end
end
