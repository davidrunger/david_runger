class MarriageDecorator < Draper::Decorator
  prepend MemoWise

  delegate_all

  memo_wise \
  def other_partner
    partner_ids = [partner_1_id, partner_2_id]
    partner_id = (partner_ids - [h.current_user.id]).first

    if partner_id
      User.find(partner_id)
    end
  end
end
