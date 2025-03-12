class MarriageDecorator < Draper::Decorator
  prepend Memoization

  delegate_all

  memoize \
  def other_partner
    partner_id = (partners.ids - [h.current_user.id]).first

    if partner_id
      User.find(partner_id)
    end
  end
end
