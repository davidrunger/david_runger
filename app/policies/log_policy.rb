# frozen_string_literal: true

class LogPolicy < ApplicationPolicy
  def show?
    (log.user == @user) ||
      log.publicly_viewable? ||
      LogShare.where(log: log, email: @user.email).exists?
  end

  private

  def log
    @record
  end
end
