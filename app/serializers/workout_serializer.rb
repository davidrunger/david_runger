# frozen_string_literal: true

# == Schema Information
#
# Table name: workouts
#
#  created_at        :datetime         not null
#  id                :bigint           not null, primary key
#  publicly_viewable :boolean          default(FALSE), not null
#  rep_totals        :jsonb            not null
#  time_in_seconds   :integer          not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_workouts_on_created_at  (created_at)
#  index_workouts_on_user_id     (user_id)
#
class WorkoutSerializer < ActiveModel::Serializer
  attributes :created_at, :id, :publicly_viewable, :rep_totals, :time_in_seconds, :username

  def rep_totals
    # alphabetize keys (workout names)
    workout.rep_totals.sort.to_h
  end

  def username
    user = workout.user
    email_username, email_domain = user.email.split('@')

    if email_username.length >= 8
      partially_anonymized_email_username = "#{email_username[0..2]}...#{email_username[-3..-1]}"
      [partially_anonymized_email_username, email_domain].join('@')
    else
      "User #{user.id}"
    end
  end

  private

  def workout
    object
  end
end
