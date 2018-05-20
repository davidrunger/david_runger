# == Schema Information
#
# Table name: exercises
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_exercises_on_user_id  (user_id)
#

class ExerciseCountsTodaySerializer < ActiveModel::Serializer
  def as_json(*_args)
    user.exercises.left_joins(:exercise_count_logs).
      where('exercise_count_logs.created_at > ?', Time.current.beginning_of_day).
      group('exercises.name').
      select(['exercises.name', 'SUM(exercise_count_logs.count) AS count']).
      map { |exercise| exercise.attributes.slice(*%w[name count]) }
  end

  private

  def user
    object
  end
end
