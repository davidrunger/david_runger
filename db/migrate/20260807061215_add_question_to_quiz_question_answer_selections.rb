class AddQuestionToQuizQuestionAnswerSelections < ActiveRecord::Migration[8.1]
  INDEX_NAME = 'uniq_quiz_answer_selections_on_participation_and_question'

  def up
    add_reference(
      :quiz_question_answer_selections,
      :question,
      foreign_key: { on_delete: :cascade, to_table: :quiz_questions },
      null: true,
    )

    execute(<<~SQL.squish)
      UPDATE quiz_question_answer_selections
      SET question_id = quiz_question_answers.question_id
      FROM quiz_question_answers
      WHERE quiz_question_answer_selections.answer_id = quiz_question_answers.id
    SQL

    execute(<<~SQL.squish)
      DELETE FROM quiz_question_answer_selections
      USING quiz_participations, quiz_questions
      WHERE quiz_question_answer_selections.participation_id = quiz_participations.id
        AND quiz_question_answer_selections.question_id = quiz_questions.id
        AND quiz_participations.quiz_id <> quiz_questions.quiz_id
    SQL

    execute(<<~SQL.squish)
      DELETE FROM quiz_question_answer_selections AS duplicate_selection
      USING quiz_question_answer_selections AS original_selection
      WHERE duplicate_selection.participation_id = original_selection.participation_id
        AND duplicate_selection.question_id = original_selection.question_id
        AND duplicate_selection.id > original_selection.id
    SQL

    change_column_null :quiz_question_answer_selections, :question_id, false
    add_index(
      :quiz_question_answer_selections,
      %i[participation_id question_id],
      name: INDEX_NAME,
      unique: true,
    )
    remove_index :quiz_question_answer_selections, :participation_id
  end

  def down
    remove_reference(
      :quiz_question_answer_selections,
      :question,
      foreign_key: { to_table: :quiz_questions },
    )
    add_index :quiz_question_answer_selections, :participation_id
  end
end
