# frozen_string_literal: true

class NeedSatisfactionRatings::Update < ApplicationAction
  requires :need_satisfaction_rating, NeedSatisfactionRating
  requires :attributes, Hash
  requires :current_user, User

  def execute
    need_satisfaction_rating.update!(attributes)

    if check_in.decorate.submitted_by_both_partners?
      CheckInsChannel.from(current_user).broadcast_to(
        check_in.marriage,
        event: 'need-satisfaction-rating-updated',
        rating: need_satisfaction_rating,
      )
    end
  end

  private

  def check_in
    need_satisfaction_rating.check_in
  end
end
