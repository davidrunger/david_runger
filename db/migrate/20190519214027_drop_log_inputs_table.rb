# frozen_string_literal: true

class DropLogInputsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :log_inputs
  end
end
