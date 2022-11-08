# frozen_string_literal: true

class CheckInSubmissions::Create < ApplicationAction
  requires :submission, CheckInSubmission
  requires :user, User

  def execute
    submission.save!

    if check_in.decorate.submitted_by_partner?
      CheckInsChannel.broadcast_to(
        check_in.marriage,
        event: 'check-in-submitted',
        ratings: user_ratings_of_partner,
      )
    end
  end

  private

  def user_ratings_of_partner
    ActiveModel::Serializer::CollectionSerializer.new(
      check_in.need_satisfaction_ratings.
        where(user:).
        includes(:emotional_need).
        order('emotional_needs.name'),
    )
  end

  def check_in
    submission.check_in
  end
end
