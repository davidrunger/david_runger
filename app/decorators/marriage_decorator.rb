class MarriageDecorator < Draper::Decorator
  prepend Memoization

  delegate_all

  memoize \
  def other_partner
    partner_ids = [partner_1_id, partner_2_id]
    partner_id = (partner_ids - [h.current_user.id]).first

    if partner_id
      User.find(partner_id)
    end
  end
end
