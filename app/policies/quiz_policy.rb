# frozen_string_literal: true

class QuizPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Quiz.all
    end
  end
end
