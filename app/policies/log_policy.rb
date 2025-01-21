class LogPolicy < ApplicationPolicy
  def show?
    own_record? || log.publicly_viewable? || LogShare.exists?(log:, email: @user&.email)
  end

  private

  def log
    @record
  end

  def own_record?
    log.user == @user
  end
end
