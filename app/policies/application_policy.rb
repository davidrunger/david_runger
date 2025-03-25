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
    @user.is_a?(User)
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
    if @record.respond_to?(:user_id)
      # if possible, avoid loading the record's user for better performance
      @record.user_id == @user.id
    else
      # only load the user record if necessary
      @record.user == @user
    end
  end
end
