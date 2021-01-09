# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_participations
#
#  created_at     :datetime         not null
#  display_name   :string           not null
#  id             :bigint           not null, primary key
#  participant_id :bigint           not null
#  quiz_id        :bigint           not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_quiz_participations_on_participant_id              (participant_id)
#  index_quiz_participations_on_quiz_id_and_display_name    (quiz_id,display_name) UNIQUE
#  index_quiz_participations_on_quiz_id_and_participant_id  (quiz_id,participant_id) UNIQUE
#
FactoryBot.define do
  factory :quiz_participation do
    association :participant, factory: :user
    association :quiz
    display_name { participant.email.split('@').first.titleize }
  end
end
