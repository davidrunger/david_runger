# frozen_string_literal: true

class LogPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.logs
    end
  end

  def show?
    own_record? || log.publicly_viewable? || LogShare.exists?(log: log, email: @user.email)
  end

  private

  def log
    @record
  end

  def own_record?
    log.user == @user
  end
end
