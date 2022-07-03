# frozen_string_literal: true

class MarriageDecorator < Draper::Decorator
  extend Memoist

  delegate_all

  memoize \
  def other_partner
    partners.where.not(id: h.current_user).first
  end
end
