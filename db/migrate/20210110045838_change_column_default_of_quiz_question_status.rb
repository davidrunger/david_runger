# frozen_string_literal: true

class ChangeColumnDefaultOfQuizQuestionStatus < ActiveRecord::Migration[6.1]
  def up
    change_column_default :quiz_questions, :status, 'open'
  end

  def down
    change_column_default :quiz_questions, :status, 'unstarted'
  end
end
