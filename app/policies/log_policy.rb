# frozen_string_literal: true

class LogPolicy < ApplicationPolicy
  def show?
    (log.user == @user) ||
      log.publicly_viewable? ||
      LogShare.exists?(log: log, email: @user.email)
  end

  private

  def log
    @record
  end
end
