# frozen_string_literal: true

class AuthTokenPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    @record.user == @user
  end

  def update?
    @record.user == @user
  end
end
