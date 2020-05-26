# frozen_string_literal: true

class AddIndexForWorkoutsCreatedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :workouts, :created_at
  end
end
