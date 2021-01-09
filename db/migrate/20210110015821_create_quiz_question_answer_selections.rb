# frozen_string_literal: true

class CreateQuizQuestionAnswerSelections < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_question_answer_selections do |t|
      t.references :answer, null: false, foreign_key: { to_table: 'quiz_question_answers' }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
