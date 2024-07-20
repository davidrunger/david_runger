# frozen_string_literal: true

class VuePlaygroundPolicy < ApplicationPolicy
  def index?
    @user.is_a?(AdminUser)
  end
end
