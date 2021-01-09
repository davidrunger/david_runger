# frozen_string_literal: true

class AddIndexForQuizParticipationsQuizIdAndDisplayName < ActiveRecord::Migration[6.1]
  def change
    add_index :quiz_participations, %i[quiz_id display_name], unique: true
  end
end
