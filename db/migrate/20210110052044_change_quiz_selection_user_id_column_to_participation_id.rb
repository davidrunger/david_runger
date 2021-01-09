# frozen_string_literal: true

class ChangeQuizSelectionUserIdColumnToParticipationId < ActiveRecord::Migration[6.1]
  def change
    remove_column :quiz_question_answer_selections, :user_id, :bigint
    add_reference(
      :quiz_question_answer_selections,
      :participation,
      foreign_key: { to_table: 'quiz_participations' },
      null: false,
    )
  end
end
