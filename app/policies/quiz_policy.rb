class QuizPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @scope.where(owner: @user)
    end
  end

  def show?
    true
  end

  private

  def own_record?
    @record.owner == @user
  end
end
