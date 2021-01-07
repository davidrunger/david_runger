# frozen_string_literal: true

class CreateQuizzes < ActiveRecord::Migration[6.1]
  def change
    create_table :quizzes do |t|
      t.string :name
      t.references :owner, null: false, foreign_key: { to_table: 'users' }
      t.string :status

      t.timestamps
    end
  end
end
