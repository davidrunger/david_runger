class QuizPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @scope.
        left_outer_joins(:participations).
        where(status: 'closed').
        where(
          Quiz.arel_table[:owner_id].eq(@user.id).or(
            QuizParticipation.arel_table[:participant_id].eq(@user.id),
          ),
        ).
        distinct
    end
  end
end
