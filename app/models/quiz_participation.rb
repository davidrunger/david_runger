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
#  index_quiz_participations_on_quiz_id_and_participant_id  (quiz_id,participant_id) UNIQUE
#
class QuizParticipation < ApplicationRecord
  belongs_to :quiz
  belongs_to :participant, class_name: 'User'

  validates :display_name, presence: true
  validates :participant_id, uniqueness: { scope: :quiz_id }
end
