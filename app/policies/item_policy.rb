# frozen_string_literal: true

class ItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.items
    end
  end
end
