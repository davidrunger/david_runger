class CheckInDecorator < Draper::Decorator
  prepend Memoization

  delegate_all

  memoize \
  def check_in_number
    marriage.check_ins.where(check_ins: { created_at: ..created_at }).size
  end

  memoize \
  def submitted_by_both_partners?
    submitted_by_partner? && submitted_by_self?
  end

  memoize \
  def all_ratings_scored_by_self?
    own_ratings.completed.size == emotional_needs_for_check_in.size
  end

  memoize \
  def submitted_by_partner?
    marriage.decorate.other_partner.check_in_submissions.exists?(check_in_id: id)
  end

  memoize \
  def submitted_by_self?
    h.current_user.check_in_submissions.exists?(check_in_id: id)
  end

  memoize \
  def emotional_needs_for_check_in
    marriage.emotional_needs.where(emotional_needs: { created_at: ..created_at })
  end

  memoize \
  def pretty_created_at
    object.created_at.strftime('%-m/%-d/%y')
  end

  memoize \
  def own_ratings
    need_satisfaction_ratings.where(user: h.current_user)
  end
end
