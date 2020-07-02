# frozen_string_literal: true

class CreateWeightLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :weight_logs do |t|
      t.float :weight, null: false
      t.string :note
      t.references :user, null: false, index: false # indexed manually below

      t.timestamps
    end
    add_index :weight_logs, %i[user_id created_at]
    add_foreign_key :weight_logs, :users
  end
end
