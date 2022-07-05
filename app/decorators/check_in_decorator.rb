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
    need_satisfaction_ratings.completed.size == (emotional_needs_for_check_in.size * 2)
  end

  memoize \
  def completed_by_partner?
    partner_ratings.completed.size == emotional_needs_for_check_in.size
  end

  memoize \
  def emotional_needs_for_check_in
    marriage.emotional_needs.where('emotional_needs.created_at <= ?', created_at)
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
