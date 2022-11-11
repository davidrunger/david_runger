# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  private

  def own_record?
    @user == @record
  end
end
