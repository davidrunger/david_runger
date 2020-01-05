# frozen_string_literal: true

class ChangeLogColumnsToNotNullable < ActiveRecord::Migration[5.2]
  def change
    change_table :logs, bulk: true do |t|
      t.change :data_label, :string, null: false
      t.change :data_type, :string, null: false
    end
  end
end
