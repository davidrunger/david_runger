# frozen_string_literal: true

class CreateCheckInSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :check_in_submissions do |t|
      t.references :check_in, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :check_in_submissions, %i[check_in_id user_id], unique: true
  end
end
