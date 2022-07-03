# frozen_string_literal: true

class CheckInDecorator < Draper::Decorator
  extend Memoist

  delegate_all

  memoize \
  def check_in_number
    marriage.check_ins.where('check_ins.created_at <= ?', created_at).size
  end

  memoize \
  def completed_by_both_partners?
    need_satisfaction_ratings.completed.size == (marriage.emotional_needs.size * 2)
  end

  memoize \
  def completed_by_partner?
    partner_ratings.completed.size == marriage.emotional_needs.size
  end

  memoize \
  def pretty_created_at
    object.created_at.strftime('%-m/%-d/%y')
  end

  memoize \
  def partner_ratings
    need_satisfaction_ratings.where(user: marriage.decorate.other_partner)
  end
end
