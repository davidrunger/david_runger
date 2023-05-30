# frozen_string_literal: true

class MarriageDecorator < Draper::Decorator
  prepend MemoWise

  delegate_all

  memo_wise \
  def other_partner
    partners.where.not(id: h.current_user).first
  end
end
