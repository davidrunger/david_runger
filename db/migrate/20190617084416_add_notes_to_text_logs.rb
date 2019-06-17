# frozen_string_literal: true

class AddNotesToTextLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :text_log_entries, :note, :string
  end
end
