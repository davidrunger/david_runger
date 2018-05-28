class LatestSetsSerializer < ActiveModel::Serializer
  def as_json(*_args)
    user.exercises.joins(:exercise_count_logs).
      select(<<~SQL).
        exercises.id AS exercise_id,
        exercises.name AS exercise_name,
        exercise_count_logs.count AS count
      SQL
      group('exercises.id, exercises.name, exercise_count_logs.count').
      order('MAX(exercise_count_logs.created_at) DESC').
      limit(3).
      map { |exercise| exercise.attributes.slice(*%w[exercise_id exercise_name count]) }
  end

  private

  def user
    object
  end
end
