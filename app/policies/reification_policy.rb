class ReificationPolicy < ApplicationPolicy
  def create?
    own_record?
  end

  private

  def own_record?
    @record.reify.user_id == @user.id
  end
end
