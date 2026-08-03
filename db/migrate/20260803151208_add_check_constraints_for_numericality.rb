class AddCheckConstraintsForNumericality < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint(
      :workouts,
      'time_in_seconds > 0',
      name: 'workouts_time_in_seconds_positive',
    )

    add_check_constraint(
      :need_satisfaction_ratings,
      'score IS NULL OR score BETWEEN -3 AND 3',
      name: 'need_satisfaction_ratings_score_range',
    )
  end
end
