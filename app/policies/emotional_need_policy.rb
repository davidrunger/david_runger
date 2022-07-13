# frozen_string_literal: true

class EmotionalNeedPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.marriage.emotional_needs
    end
  end

  def own_record?
    @record.marriage_id == @user.marriage.id
  end
end
