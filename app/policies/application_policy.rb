# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    # Generally, any logged-in user should be able to access an index action.
    # The records actually available in the index will be limited by the policy scope.
    @user.is_a?(User)
  end

  def show?
    scope.exists?(id: record.id)
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    own_record?
  end

  def edit?
    update?
  end

  def destroy?
    own_record?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.none
    end
  end

  private

  def own_record?
    @record.user == @user
  end
end
