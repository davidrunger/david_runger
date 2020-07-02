# frozen_string_literal: true

class DropExercises < ActiveRecord::Migration[5.2]
  def change
    drop_table(:exercises)
  end
end
