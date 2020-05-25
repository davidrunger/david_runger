# frozen_string_literal: true

class AddPubliclyViewableToWorkouts < ActiveRecord::Migration[6.1]
  def change
    add_column :workouts, :publicly_viewable, :boolean, null: false, default: false
  end
end
