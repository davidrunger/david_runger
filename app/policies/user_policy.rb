# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show_groceries?
    @user.spouse == @record
  end

  private

  def own_record?
    @user == @record
  end
end
