# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def edit?
    # user can only edit themself
    @user == @record
  end

  def update?
    edit?
  end
end
