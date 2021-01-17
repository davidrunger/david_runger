# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_questions
#
#  content    :text             not null
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  quiz_id    :bigint           not null
#  status     :string           default("open"), not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_quiz_questions_on_quiz_id  (quiz_id)
#
class QuizQuestion < ApplicationRecord
  OPEN = 'open'
  CLOSED = 'closed'
  STATUSES = [OPEN, CLOSED].freeze

  validates :content, presence: true
  validates :status, presence: true, inclusion: STATUSES

  belongs_to :quiz

  has_many(
    :answers,
    dependent: :destroy,
    class_name: 'QuizQuestionAnswer',
    foreign_key: :question_id,
    inverse_of: :question,
  )
  has_many(
    :answer_selections,
    through: :answers,
    source: :selections,
  )

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end
end
