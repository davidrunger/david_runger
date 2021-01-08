# frozen_string_literal: true

class QuizDecorator < Draper::Decorator
  delegate_all

  def current_user_is_participating?
    participants.exists?(id: h.current_user)
  end

  def owned_by_current_user?
    h.current_user == owner
  end
end
