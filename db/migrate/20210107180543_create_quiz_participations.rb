# frozen_string_literal: true

class CreateQuizParticipations < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_participations do |t|
      # don't index because we add a multi-column index below
      t.references :quiz, null: false, foreign_key: true, index: false
      t.references :participant, null: false, foreign_key: { to_table: 'users' }
      t.string :display_name, null: false

      t.timestamps
    end

    add_index :quiz_participations, %i[quiz_id participant_id], unique: true
  end
end
