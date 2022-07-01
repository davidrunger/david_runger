# frozen_string_literal: true

class CreateNeedSatisfactionRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :need_satisfaction_ratings do |t|
      t.belongs_to :emotional_need, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :check_in, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
