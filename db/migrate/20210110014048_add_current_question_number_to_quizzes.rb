# frozen_string_literal: true

class AddCurrentQuestionNumberToQuizzes < ActiveRecord::Migration[6.1]
  def change
    add_column :quizzes, :current_question_number, :integer, null: false, default: 1
  end
end
