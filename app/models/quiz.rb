# frozen_string_literal: true

# == Schema Information
#
# Table name: quizzes
#
#  created_at              :datetime         not null
#  current_question_number :integer          default(1), not null
#  id                      :bigint           not null, primary key
#  name                    :string
#  owner_id                :bigint           not null
#  status                  :string           default("unstarted"), not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_quizzes_on_owner_id  (owner_id)
#
class Quiz < ApplicationRecord
  include Hashid::Rails

  STATUSES = %w[unstarted active closed].map(&:freeze).freeze

  validates :status, presence: true, inclusion: STATUSES

  belongs_to :owner, class_name: 'User'

  has_many(
    :participations,
    dependent: :destroy,
    class_name: 'QuizParticipation',
    inverse_of: :quiz,
  )
  has_many(
    :questions,
    dependent: :destroy,
    class_name: 'QuizQuestion',
    inverse_of: :quiz,
  )
  has_many :participants, through: :participations
  has_many(
    :question_answers,
    through: :questions,
    source: :answers,
    class_name: 'QuizQuestionAnswer',
  )

  STATUSES.each do |status|
    define_method("#{status}?") do
      self.status == status
    end
  end
end
