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
FactoryBot.define do
  factory :workout do
    association :user
    time_in_seconds { Integer(45.minutes) }
    rep_totals { {chinups: 100, pushups: 300} }
    publicly_viewable { false }
  end
end
