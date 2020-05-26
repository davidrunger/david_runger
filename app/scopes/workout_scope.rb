# frozen_string_literal: true

class WorkoutScope < Scopable
  model Workout

  scope :excluding_user do
    where.not(user_id: value)
  end
end
