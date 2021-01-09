# frozen_string_literal: true

class CreateQuizQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :content, null: false
      t.string :status, null: false, default: 'unstarted'

      t.timestamps
    end
  end
end
