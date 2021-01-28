# frozen_string_literal: true

class LogPolicy < ApplicationPolicy
  def show?
    own_record? ||
      log.publicly_viewable? ||
      LogShare.exists?(log: log, email: @user.email)
  end

  private

  def log
    @record
  end

  def own_record?
    log.user == @user
  end
end
