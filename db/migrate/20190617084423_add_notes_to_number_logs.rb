# frozen_string_literal: true

class AddNotesToNumberLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :number_log_entries, :note, :string
  end
end
