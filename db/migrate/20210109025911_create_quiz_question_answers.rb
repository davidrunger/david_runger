# frozen_string_literal: true

class CreateQuizQuestionAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_question_answers do |t|
      t.references :question, null: false, foreign_key: { to_table: 'quiz_questions' }
      t.text :content, null: false
      t.boolean :is_correct, null: false, default: false

      t.timestamps
    end
  end
end
